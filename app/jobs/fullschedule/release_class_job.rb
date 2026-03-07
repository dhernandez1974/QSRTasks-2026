class ReleaseClassJob < ApplicationJob
  queue_as :default

  def perform(token_id, type)
    if type == "employee"
      student = User.find_by(token_id: token_id)
    end
    content_type = 'application/json'
    x_api_key = Rails.application.credentials.dig(:fullschedule, :api)
    url = URI.parse("https://api.fullschedule.com/thirdparty/vendor/token/release")
    data = {
      "id": token_id.to_s,
      "override": "true",
    }
    response = create_request(url, data, content_type, x_api_key)
    payload = JSON.parse(response.body, symbolize_names: true)
    if response.code.to_i == 200
      if type == "employee"
        student.update(token_id: nil, fh_status: "No Certificate", invite_url: nil)
      end
    else
      FullscheduleMailer.fullschedule_api_info(payload, token_id, type, url.to_s, data).deliver_later
    end
  end

  def create_request(url, data, content_type, x_api_key)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(url.path, {'Content-Type' => content_type, 'x-api-key' => x_api_key})
    request.body = data.to_json
    http.request(request)
  end
end
