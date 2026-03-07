class CreateCandidateJob < ApplicationJob
  queue_as :default

  def perform(new_hire_id, type)
    if type == "newhire"
      new_hire = NewHire.find(new_hire_id)
    else
      new_hire = User.find(new_hire_id)
    end
    content_type = 'application/json'
    url = URI.parse('https://api.checkr.com/v1/candidates')
    data = {
      "email": new_hire.email,
      "custom_id": new_hire.id.to_s,
      "metadata": { age: get_age(new_hire.birthdate).to_s,
                    location: type == "newhire" ? new_hire.store.number.to_s : new_hire.stores[0].number.to_s,
                    auto: "yes",
                    type: type,
        },
    }
    response = create_request(url, data, content_type)
    payload = JSON.parse(response.body, symbolize_names: true)
    if response.code.to_i == 201
      new_hire.update(checkr_status: "Candidate Created", checkr_id: payload[:id], checkr_result: "Candidate Created")
      CreateInvitationJob.perform_later(new_hire.id, payload, type)
    else
      CheckrMailer.create_candidate_info(new_hire, payload, response.code.to_i).deliver_later
      SendHireSmsJob.perform_later(new_hire, "#{new_hire.full_name} @ #{type == "newhire" ? new_hire.store.number : new_hire.stores[0].number} was not able
        to be added to Checkr. Please login to Checkr and add them manually.")
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

  def get_age(birthdate)
    now = Time.now.utc.to_date
    now.year - birthdate.year - (birthdate.to_date.change(:year => now.year) > now ? 1 : 0)
  end
end
