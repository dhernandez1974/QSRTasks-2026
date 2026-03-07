class GetPdfCertificateJob < ApplicationJob
  queue_as :default

  def perform(student_id, type)
    if type == "newhire"
      student = NewHire.find(student_id)
    else
      student = User.find(student_id)
    end
    id = student.certificate_id
    content_type = 'application/json'
    x_api_key = Rails.application.credentials.dig(:fullschedule, :api)
    url = URI.parse("https://api.fullschedule.com/thirdparty/vendor/certificate-pdf/#{id}")
    response = create_request(url, content_type, x_api_key)
    payload = JSON.parse(response.body, symbolize_names: true)
    if response.code.to_i == 200
      base_64_data = payload[:data][:base64]
      decoded_data = Base64.decode64(base_64_data)
      blob = ActiveStorage::Blob.create_and_upload!(
        io: StringIO.new(decoded_data),
        filename: payload[:data][:filename],
        content_type: payload[:data][:mime]
      )
      if type == "newhire"
        student.update(picture: blob, food_handler: true)
      else
        if student.food_handler_card.nil?
        FoodHandlerCard.new(organization_id: student.organization.id, user_id: student.id,
          picture: blob, store_id: student.stores[0].id, issue_date: student.fh_created_at,
          expiration_date: student.fh_expires_at).save
        else
          student.food_handler_card.update(picture: blob, issue_date: student.fh_created_at,
            expiration_date: student.fh_expires_at)
        end
      end
    else
      FullscheduleMailer.fullschedule_api_info(payload, student_id, type, url.to_s, id).deliver_later
    end
  end

  def create_request(url, content_type, x_api_key)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(url.path, {'Content-Type' => content_type, 'x-api-key' => x_api_key})
    http.request(request)
  end
end
