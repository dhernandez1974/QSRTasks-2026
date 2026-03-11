module Datapass
  class OrganizationUserInfoJob < ApplicationJob
    queue_as :default

    TARGET_TOPICS = %w[HR-EmployeeDetails LZ-HR-IdMgmtFull LZ-HR-Identification LZ-HR-SSN LZ-HR-Personal
LZ-HR-EmployeeHistory].freeze

    # Scans the datapass S3 bucket for the previous N days and reprocesses matching files
    # by enqueueing DatapassWebhookRouter with application/json content type (filename lookup path).
    #
    # Required:
    # - organization_ids: Array<Integer> of one or more organization ids to filter by EIDs
    # Options:
    # - days: how many days back to include (default7, inclusive of today)
    # - topics: override topics to backfill (subset of TARGET_TOPICS)
    def perform(organization_ids:, days: 7, topics: TARGET_TOPICS)
      raise ArgumentError, "organization_ids must be provided" if organization_ids.blank?

      # Build a case-insensitive set of EIDs (include both eid and secondary_eids for safety)
      eid_pairs = Organization.where(id: organization_ids).pluck(:eid, :secondary_eids)
      if eid_pairs.blank?
        Rails.logger.warn("OrganizationUserInfoJob: No organizations found for ids=#{organization_ids.inspect}")
        return 0
      end
      eid_set = Set.new
      eid_pairs.each do |eid, secondary|
        eid_set << eid.to_s.downcase if eid.present?
        if secondary.is_a?(Array)
          secondary.each { |s| eid_set << s.to_s.downcase if s.present? }
        end
      end

      creds = Rails.application.credentials.aws_datapass || {}
      access_key_id     = creds[:access_key_id] || creds[:key] || ENV["AWS_ACCESS_KEY_ID"]
      secret_access_key = creds[:secret_access_key] || creds[:secret] || ENV["AWS_SECRET_ACCESS_KEY"]
      region            = creds[:region] || ENV["AWS_REGION"] || "us-east-1"
      bucket            = creds[:bucket_name] || ENV["AWS_DATAPASS_BUCKET"]

      raise "aws_datapass.bucket_name missing in credentials or AWS_DATAPASS_BUCKET env" if bucket.blank?

      s3 = Aws::S3::Client.new(
        access_key_id: access_key_id,
        secret_access_key: secret_access_key,
        region: region
      )

      cutoff_start = (Time.zone.now.beginning_of_day - (days - 1).days).utc
      cutoff_end   = Time.zone.now.end_of_day.utc

      prefix = "prod/" # matches DatapassWebhookRouterJob.retrieve_file_from_s3

      continuation_token = nil
      matched = 0
      webhooks_to_create = []

      loop do
        resp = s3.list_objects_v2(bucket: bucket, prefix: prefix, continuation_token: continuation_token)
        (resp.contents || []).each do |obj|
          filename = File.basename(obj.key.to_s)
          parts = parse_filename(filename)
          next if parts.nil?
          next unless topics.include?(parts[:topic])
          ts = parts[:captured_at]
          next if ts.nil? || ts < cutoff_start || ts > cutoff_end

          owner_eid = parts[:mcopco_or_eid].to_s.downcase
          next unless eid_set.include?(owner_eid)

          webhooks_to_create << { body: { filename: filename }.to_json }
          matched += 1
        end

        break unless resp.is_truncated
        continuation_token = resp.next_continuation_token
      end

      if webhooks_to_create.any?
        created_webhooks = InboundWebhook.insert_all(webhooks_to_create, returning: %w[id])
        created_webhooks.each do |row|
          webhook = InboundWebhook.find(row["id"])
          Datapass::DatapassWebhookRouterJob.perform_later(webhook, "application/json")
        end
      end

      Rails.logger.info("OrganizationUserInfoJob enqueued router for #{matched} files across topics: #{topics.join(", ")} for org_ids=#{organization_ids.inspect}")
      matched
    end

    private

    # Parse filename of the form:
    # <7 digit NSN>_<Data source>_<Topic>_<Topic ID>_<Version>_<yyyyMMddHHmmssSSS>_<Mcopco or eID>.<format>.enc
    def parse_filename(filename)
      regex = /\A(?<nsn>\d{7})_(?<data_source>[^_]+)_(?<topic>[^_]+)_(?<topic_id>[^_]+)_(?<version>[^_]+)_(?<ts>\d{17})_(?<owner>[^.]+)\.(?<format>[A-Za-z0-9_\-]+)\.enc\z/
      m = filename.match(regex)
      return nil unless m

      captured_at = begin
        Time.strptime(m[:ts], "%Y%m%d%H%M%S%L").utc
      rescue ArgumentError
        nil
      end

      {
        nsn: m[:nsn],
        data_source: m[:data_source],
        topic: m[:topic],
        topic_id: m[:topic_id],
        version: m[:version],
        captured_at: captured_at,
        mcopco_or_eid: m[:owner],
        file_format: m[:format]
      }
    end
  end
end
