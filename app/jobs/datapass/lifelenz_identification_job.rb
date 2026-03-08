class Datapass::LifelenzIdentificationJob < ApplicationJob
  queue_as :default

  def perform(data, nsn, timestamp)
    # The input data could be a JSON string, a Ruby-style hash string, or a pre-parsed hash/array.
    payload = parse_payload(data)
    return if payload.nil?

    location = Organization::Location.find_by(number: nsn.to_i.to_s)
    if location.nil?
      puts "Location not found for NSN: #{nsn}"
      return
    end

    organization = location.organization

    payload.each do |record|
      geid = record["GEID"].to_s
      next if geid.blank?

      identification = Datapass::Identification.find_or_initialize_by(geid: geid, organization_id: organization.id)

      identification.assign_attributes(
        location_id: location.id,
        first_name: record["FirstName"],
        nickname: record["NickName"],
        last_initial: record["LastInitial"],
        primary_time_card: record["PrimaryTimeCard"],
        secondary_time_card: record["SecondaryTimeCard"],
        home_store_nsn: record["HomeStoreNSN"],
        unique_id: record["UniqueID"],
        birth_day: parse_date(record["BirthDay"]),
        ssn: record["SSN"],
        email_address: record["EmailAddress"],
        zip_code: record["ZipCode"],
        ethnicity: record["Ethinicity"], # Note the typo in the source "Ethinicity"
        gender: record["Gender"],
        emp_job_title_history: record["EmpJobTitleHistory"]
      )

      unless identification.save
        puts "Failed to save Identification record for GEID #{geid}: #{identification.errors.full_messages.join(', ')}"
      end
    end
  end

  private

  def parse_payload(data)
    return data if data.is_a?(Array) || data.is_a?(Hash)
    
    begin
      JSON.parse(data.gsub('=>', ':'))
    rescue JSON::ParserError, TypeError => e
      # If it's not JSON, it might be a Ruby hash string.
      begin
        # Use a safer evaluation if possible, but for this specific context:
        eval(data)
      rescue StandardError => e2
        puts "Failed to parse identification payload: #{e.message} / #{e2.message}"
        nil
      end
    end
  end

  def parse_date(date_str)
    return nil if date_str.blank?
    begin
      Date.strptime(date_str.to_s, "%Y%m%d")
    rescue Date::Error
      nil
    end
  end
end
