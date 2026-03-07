class RefillTokensJob < ApplicationJob
  queue_as :default

  def perform(*args)
    content_type = 'application/json; charset=utf-8'
    x_api_key = Rails.application.credentials.dig(:fullschedule, :api)
    url = URI.parse("https://api.fullschedule.com/thirdparty/vendor/token/purchase")
    data = {
      "course": "food-handler-tx",
      "qty": 100
    }
    response = create_request(url, data, content_type, x_api_key)
    payload = JSON.parse(response.body, symbolize_names: true)
    if response.code.to_i == 200

    else
      FullscheduleMailer.fullschedule_api_info(payload).deliver_later
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
