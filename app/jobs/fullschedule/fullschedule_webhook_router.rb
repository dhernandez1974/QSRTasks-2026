class FullscheduleWebhookRouter < ApplicationJob
  queue_as :default

  def perform(inbound_webhook)
    webhook_payload = JSON.parse(inbound_webhook.body, symbolize_names: true)
    if webhook_payload[:data][:metadata][:student_type] == "newhire"
      student = NewHire.find_by(email: webhook_payload[:data][:user][:email])
    else
      student = User.find_by(email: webhook_payload[:data][:user][:email])
    end
    case webhook_payload[:event]
    when "token.bulk-purchase" # This is the event that is triggered when a bulk purchase of tokens is made
      #just fyi?
    when "token.redeemed" # This is the event that is triggered when a course is started
      student.update(fh_status: "In Progress")
    when "token.completed" # This is the event that is triggered when a course is completed
      student.update(certificate_id: webhook_payload[:data][:certificate_id], fh_status: "Completed",
        fh_created_at: Time.at(webhook_payload[:data][:completed_at]), fh_expires_at: Time.at(webhook_payload[:data][:expires_at]))
      GetPdfCertificateJob.perform_later(student.id, webhook_payload[:data][:metadata][:student_type])
    else
      FullscheduleMailer.fullschedule_webhook_info(webhook_payload).deliver_later
    end
    inbound_webhook.update(status: :processed)
  end

end