class CertificationSearchJob < ApplicationJob
  queue_as :default

  def perform(student_id, type)
    if type == "newhire"
      student = NewHire.find(student_id)
    else
      student = User.find(student_id)
    end
    content_type = 'application/json; charset=utf-8'
    x_api_key = Rails.application.credentials.dig(:fullschedule, :api)
    url = URI.parse("https://api.fullschedule.com/thirdparty/vendor/student/search")
    data = {
      "email": student.email
    }
    response = create_request(url, data, content_type, x_api_key)
    payload = JSON.parse(response.body, symbolize_names: true)
    if response.code.to_i == 200
      student.update(certificate_id: payload[:data][:certifications][0][:certificate_number],
        fh_created_at: Time.at(payload[:data][:certifications][0][:completed_at]),
        fh_expires_at: Time.at(payload[:data][:certifications][0][:expires_at]), fh_status: payload[:data][:certifications][0][:status])
      GetPdfCertificateJob.perform_later(student.id, type)
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
