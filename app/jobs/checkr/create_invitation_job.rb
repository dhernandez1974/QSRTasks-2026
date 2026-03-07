class CreateInvitationJob < ApplicationJob
  queue_as :default

  def perform(new_hire_id, webhook_payload, type)
    if type == "newhire"
      new_hire = NewHire.find(new_hire_id)
    else
      new_hire = User.find(new_hire_id)
    end
    content_type = 'application/json'
    url = URI.parse('https://api.checkr.com/v1/invitations')
    if type == "newhire"
      package = webhook_payload[:metadata][:age].to_i < 18 ? "goodhire_basic_package_for_minors" : "goodhire_basic_package_digitized_national_criminal"
    else
      package = "goodhire_extended_criminal_package_national_criminal_unlimited_county"
    end
    data = {
      "candidate_id": webhook_payload[:id],
      "package": package,
      "node": webhook_payload[:metadata][:location].to_s,
      "work_locations": ["country":"US", "state": "TX", "city": type == "newhire" ? new_hire.store.city : new_hire.stores[0].city],
    }
    response = create_request(url, data, content_type)
    payload = JSON.parse(response.body, symbolize_names: true)
    if response.code.to_i == 201
      new_hire.update(checkr_status: "Invitation Sent", bcgd_url: payload[:invitation_url], checkr_result: "Invitation Sent")
      SendBackgroundSmsJob.perform_later(new_hire, "Here is the link to complete your background check:
#{payload[:invitation_url]} This link will expire in 7 days. If the link expires you will need to apply again")
    else
      CheckrMailer.create_invitation_info(new_hire, payload, response.code.to_i).deliver_later
      SendHireSmsJob.perform_later(new_hire, "#{new_hire.full_name} @ #{type == "newhire" ? new_hire.store.number : new_hire.stores[0].city}. Checkr was not able to create an invitation link for the background check. #{payload[:error]}")
    end
  end

  def create_request(url, data, content_type)
    idempotency_key = SecureRandom.uuid
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(url.path, {'Content-Type' => content_type})
    request.basic_auth(Rails.application.credentials.dig(:checkr, :api), '')
    request['Idempotency-Key'] = idempotency_key
    request.body = data.to_json
    http.request(request)
  end
end
