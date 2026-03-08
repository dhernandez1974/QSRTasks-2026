class Datapass::GeidMatchJob < ApplicationJob
  queue_as :default

  def perform(data, nsn, timestamp)
    store = Organization::Location.find_by(number: nsn.to_i)
    return unless store

    # data can be a String or an Array of hashes (depending on how it's passed from Router)
    # The sample file shown had Ruby hash syntax [{"GEID" => "516141", ...}]
    # If it's a string from a file that looks like that, we might need to eval or fix it.
    # However, DatapassWebhookRouter usually parses JSON or handles CSV.
    
    records = if data.is_a?(String)
                # Handle potential Ruby hash syntax in what should be JSON
                begin
                  JSON.parse(data.gsub('=>', ':'))
                rescue JSON::ParserError
                  # Fallback or handle differently if needed
                  []
                end
              else
                data
              end

    return unless records.is_a?(Array)

    records.each do |record|
      geid = record['GEID']
      ssn = record['SSN']
      next if geid.blank? || ssn.blank?

      geid_match = Datapass::HrSsn.find_or_initialize_by(
        organization_id: store.organization_id,
        geid: geid
      )
      geid_match.ssn = ssn
      geid_match.save!
    end
  end
end
