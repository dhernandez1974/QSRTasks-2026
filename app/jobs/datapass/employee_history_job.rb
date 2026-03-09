class Datapass::EmployeeHistoryJob < ApplicationJob
  queue_as :default

  def perform(file_path = "tmp/0001480-LIFELENZ-LZ-HR-EmployeeHistory.json")
    full_path = File.expand_path(file_path, Rails.root)
    unless File.exist?(full_path)
      Rails.logger.error "EmployeeHistoryJob: File not found at #{full_path}"
      return
    end

    begin
      file_content = File.read(full_path)
      # Some files use => which is not standard JSON, let's normalize it.
      normalized_content = file_content.gsub('=>', ':')
      data = JSON.parse(normalized_content)
    rescue JSON::ParserError => e
      # Try original content if normalization failed for some reason
      begin
        data = JSON.parse(file_content)
      rescue JSON::ParserError => e2
        Rails.logger.error "EmployeeHistoryJob: Failed to parse JSON: #{e2.message}"
        return
      end
    end

    data.each do |entry|
      process_entry(entry)
    end
  end

  private

  def process_entry(entry)
    geid = entry["GEID"].to_s
    return if geid.blank?

    # Try to find organization and location from StoreHistory
    home_store = entry["StoreHistory"]&.find { |s| s["HomeOrShared"] == "Home" } || entry["StoreHistory"]&.first
    
    location = nil
    organization = nil
    
    if home_store
      nsn = home_store["Store"].to_i.to_s
      location = Organization::Location.find_by(number: nsn)
      organization = location&.organization
    end

    if location.nil? || organization.nil?
      # Fallback to any organization if we have a default one in the system or just skip
      # For now, let's skip as they are required by the migration.
      # Rails.logger.warn "EmployeeHistoryJob: Could not find location/organization for GEID #{geid}"
      return
    end

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
