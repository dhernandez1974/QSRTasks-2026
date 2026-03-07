class RetrieveCandidateJob < ApplicationJob
  queue_as :default

  def perform(webhook_payload, message)
    url = URI.parse("https://api.checkr.com/v1/candidates/#{webhook_payload[:data][:object][:candidate_id]}")
    response = create_request(url)
    payload = JSON.parse(response.body, symbolize_names: true)
    if response.code.to_i == 200
      new_hire = NewHire.find_by(email: payload[:email])
      if new_hire
        CheckrMailer.retrieve_candidate_info(webhook_payload, payload, response.code.to_i).deliver_later
      else
        CheckrMailer.candidate_invitation_created_manually(payload).deliver_later
      end
      case message
      when "invitation created"
        TwilioClient.new.send_text(User.find(2),"Invitation created manually for #{payload[:first_name]} #{payload[:last_name]} (#{payload[:email]}")
        if new_hire
          new_hire.update(checkr_status: message, checkr_id: payload[:id], bcgd_url: webhook_payload[:data][:object][:invitation_url], checkr_result: "Invitation Sent")
        end
      when "report completed"
        TwilioClient.new.send_text(User.find(2),"report created manually for #{payload[:first_name]} #{payload[:last_name]} (#{payload[:email]} result is #{webhook_payload[:data][:object][:result]})")
        if webhook_payload[:data][:object][:result] == "clear" && new_hire
          new_hire.update(checkr_status: message, background_received: true, background_ok: true, checkr_result: "Approved")
          SendNewHireBackgroundSmsJob.perform_later(new_hire, "#{new_hire.full_name} at #{new_hire.store.number} background check was approved⭐️⭐️")
        elsif new_hire
          new_hire.update(checkr_status: "report completed", checkr_result: "Needs Review") #TODO what if clear but no nh
        else
          CheckrMailer.retrieve_candidate_info(webhook_payload, payload, response.code.to_i).deliver_later
        end
        #TODO need logic here to update hiring status for onboarding
      else

      end
    else
      CheckrMailer.retrieve_candidate_info(webhook_payload, payload, response.code.to_i).deliver_later
    end

  end

  def create_request(url)
    idempotency_key = SecureRandom.uuid
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(url.path)
    request.basic_auth(Rails.application.credentials.dig(:checkr, :api), '')
    request['Idempotency-Key'] = idempotency_key
    http.request(request)
  end
end

