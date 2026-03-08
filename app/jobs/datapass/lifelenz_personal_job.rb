class Datapass::LifelenzPersonalJob < ApplicationJob
  queue_as :default

  def perform(data, nsn, timestamp)
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

      hr_personal = Datapass::HrPersonal.find_or_initialize_by(geid: geid, organization_id: organization.id)

      hr_personal.assign_attributes(
        location_id: location.id,
        first_name: record["FirstName"],
        last_name: record["LastName"],
        middle_initial: record["MiddleInitial"],
        nickname: record["NickName"],
        date_of_birth: parse_date(record["DateOfBirth"]),
        street_address: record["StreetAddress"],
        apt_number: record["AptNumber"],
        city: record["City"],
        state: record["State"],
        zip_code: record["ZipCode"],
        home_phone_number: record["HomePhoneNumber"],
        cell_phone_number: record["CellPhoneNumber"],
        email_address: record["EmailAddress"],
        payroll_id: record["PayrollID"].to_s,
        personal_marital_status: record["PersonalMaritalStatus"],
        gender: record["Gender"],
        national_origin: record["NationalOrigin"],
        student_status: record["StudentStatus"].to_s,
        student_permit_expiration_date: parse_date(record["StudentPermitExpirationDate"]),
        military_vateran_status: record["MilitaryVeteranStatus"].to_s,
        veteran_type: record["VeteranType"],
        disabled_veteran: record["DisabledVeteran"].to_s,
        emergency_contact_first_name: record["EmergencyContactFirstName"],
        emergency_contact_last_name: record["EmergencyContactLastName"],
        emergency_contact_home_phone_number: record["EmergencyContact-HomePhoneNumber"],
        emergency_contact_cell_phone_number: record["EmergencyContact-CellPhoneNumber"],
        emergency_contact_work_phone_number: record["EmergencyContact-WorkPhoneNumber"],
        primary_time_card: record["PrimaryTimeCard"],
        secondary_time_card: record["SecondaryTimeCard"],
        unique_id: record["UniqueID"]
      )

      unless hr_personal.save
        puts "Failed to save HrPersonal record for GEID #{geid}: #{hr_personal.errors.full_messages.join(', ')}"
      end
    end
  end

  private

  def parse_payload(data)
    return data if data.is_a?(Array) || data.is_a?(Hash)
    
    begin
      JSON.parse(data.gsub('=>', ':'))
    rescue JSON::ParserError, TypeError => e
      begin
        eval(data)
      rescue StandardError => e2
        puts "Failed to parse personal payload: #{e.message} / #{e2.message}"
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
