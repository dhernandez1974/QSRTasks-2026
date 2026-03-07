class AssignClassJob < ApplicationJob
  queue_as :default

  def perform(student_id, type, manager_id)
    manager = User.find(manager_id)
    if type == "newhire"
      student = NewHire.find(student_id)
    else
      student = User.find(student_id)
    end
    content_type = 'application/json; charset=utf-8'
    x_api_key = Rails.application.credentials.dig(:fullschedule, :api)
    url = URI.parse('https://api.fullschedule.com/thirdparty/vendor/token/assign')
    data = {
      "course": "food-handler-tx",
      "first_name": student.first_name,
      "last_name": student.last_name,
      "email": student.email,
      "send_email": false,
      "store_id": type == "newhire" ? student.store.number.to_s : student.stores[0].number.to_s,
      "employee_id": student.id.to_s,
      "manager_name": manager.full_name,
      "metadata": { "student_type": type, "id": student.id.to_s }
    }
    response = create_request(url, data, content_type, x_api_key)
    payload = JSON.parse(response.body, symbolize_names: true)
    if response.code.to_i == 200
      student.update(invite_url: payload[:data][:invite_url], token_id: payload[:data][:id], fh_status: "Link Sent")
      FullscheduleMailer.fullschedule_url_email(student, payload[:data][:invite_url].to_s).deliver_later
    else
      FullscheduleMailer.fullschedule_api_info(payload, student_id, type, url.to_s, data).deliver_later
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

#TODO: Update the failed response to check if a certificate id is present. if so, update fh_status, issue_date and expires_at date.
# then get pdf and update.