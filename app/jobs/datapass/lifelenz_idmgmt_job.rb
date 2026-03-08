class Datapass::LifelenzIdmgmtJob < ApplicationJob
  queue_as :default

  def perform(data, nsn, timestamp)
    # data can be a Hash (if JSON.parse was already called in DatapassWebhookRouterJob) or a string.
    # DatapassWebhookRouterJob: payload_file = decrypt_payload(passphrase, enc_hash[:payload_json_enc_b64], filetype)
    # In DatapassWebhookRouterJob, for filetype "json", it returns the parsed Hash.
    
    payload = data.is_a?(String) ? JSON.parse(data) : data
    return if payload.nil?

    location = Organization::Location.find_by(number: nsn.to_i.to_s)
    if location.nil?
      puts "Location not found for NSN: #{nsn}"
      return
    end

    organization = location.organization
    
    country = payload["country"]
    gerid = payload["gerid"]
    glin = payload["ids"]&.find { |id| id["type"] == "glin" }&.dig("value")

    payload["people"]&.each do |person_entry|
      person = person_entry["person"]
      next if person.nil?

      geid = person["ids"]&.find { |id| id["type"] == "geid" }&.dig("value")
      payroll_id = person["ids"]&.find { |id| id["type"] == "payroll" }&.dig("value")
      modified = parse_date(person["modified"])

      idmgmt = Datapass::Idmgmt.find_or_initialize_by(geid: geid, organization_id: organization.id, modified: modified)
      
      idmgmt.assign_attributes(
        location_id: location.id,
        nsn: nsn,
        country: country,
        gerid: gerid,
        glin: glin,
        first_name: person["first_name"],
        last_name: person["last_name"],
        middle_initial: person["middle_initial"],
        email: person["email"],
        payroll_id: payroll_id,
        organization_start_date: parse_date(person["organization_start_date"]),
        organization_termination_date: parse_date(person["organization_termination_date"]),
        termination_code: person["TerminationCode"],
        matching_criteria: person["matching_criteria"],
        shares: person["shares"],
        jtcs: person["jtcs"],
        phones: person["phones"]
      )

      unless idmgmt.save
        puts "Failed to save Idmgmt record for geid #{geid}: #{idmgmt.errors.full_messages.join(', ')}"
      end
    end
  end

  private

  def parse_date(date_str)
    return nil if date_str.blank?
    begin
      Date.strptime(date_str, "%Y%m%d")
    rescue Date::Error
      nil
    end
  end
end
