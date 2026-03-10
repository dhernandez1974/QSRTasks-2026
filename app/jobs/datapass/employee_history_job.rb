class Datapass::EmployeeHistoryJob < ApplicationJob
  queue_as :default

  def perform(data, nsn, timestamp)
    payload = data.is_a?(String) ? JSON.parse(data) : data
    return if payload.nil?

    # Try to find location from nsn
    location = Organization::Location.find_by(number: nsn.to_i.to_s)
    if location.nil?
      # puts "Location not found for NSN: #{nsn}"
      return
    end

    organization = location.organization

    payload.each do |entry|
      process_entry(entry, location, organization)
    end
  end

  private

  def process_entry(entry, location, organization)
    geid = entry["GEID"].to_s
    return if geid.blank?

    history = Datapass::EmployeeHistory.find_or_initialize_by(geid: geid, organization_id: organization.id)
    
    history.assign_attributes(
      location_id: location.id,
      organization_start_date: parse_date(entry["OrganizationStartDate"]),
      termination_date: parse_date(entry["TerminationDate"]),
      orientation_date: parse_date(entry["OrientationDate"]),
      company_service_date: parse_date(entry["CompanyServiceDate"]),
      review_due_date: parse_date(entry["ReviewDueDate"]),
      follow_up_orientation_date: parse_date(entry["FollowUpOrientationDate"]),
      termination_entry_date: parse_date(entry["TerminationEntryDate"]),
      termination_reason: entry["TerminationReason"],
      termination_code: entry["TerminationCode"],
      store_history: entry["StoreHistory"],
      repeating_full_jtc_history: entry["RepeatingFullJTCHistory"]
    )

    unless history.save
      # Rails.logger.error "EmployeeHistoryJob: Failed to save record for GEID #{geid}: #{history.errors.full_messages.join(', ')}"
    end
  end

  def parse_date(date_val)
    return nil if date_val.blank?
    begin
      # Handle YYYYMMDD format
      Date.strptime(date_val.to_s, "%Y%m%d")
    rescue Date::Error, ArgumentError
      nil
    end
  end
end
