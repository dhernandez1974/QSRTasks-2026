class CheckrWebhookRouter < ApplicationJob
  queue_as :default

  def perform(inbound_webhook)
    webhook_payload = JSON.parse(inbound_webhook.body, symbolize_names: true)
    case webhook_payload[:type]
    when 'candidate.id_required'
      new_hire = get_candidate(webhook_payload)
      if new_hire
        new_hire.update(checkr_status: "ID Required", checkr_result: "ID Required")
      else
        CheckrMailer.checkr_webhook_info(webhook_payload).deliver_later
      end
    when 'candidate.driver_license_required'
      new_hire = get_candidate(webhook_payload)
      if new_hire
        new_hire.update(checkr_status: "DL Required", checkr_result: "DL Required")
      else
        CheckrMailer.checkr_webhook_info(webhook_payload).deliver_later
      end
    when 'candidate.updated'
      new_hire = get_candidate(webhook_payload)
      if new_hire
        new_hire.update(checkr_status: "Candidate Updated", checkr_result: "Candidate Updated")
      else
        CheckrMailer.checkr_webhook_info(webhook_payload).deliver_later
      end
    when 'candidate.pre_adverse_action'

    when 'candidate.post_adverse_action'

    when 'invitation.completed'
      new_hire = get_candidate_info(webhook_payload)
      if new_hire
        new_hire.update(checkr_status: "Submitted", checkr_result: "Submitted")
      else
        CheckrMailer.checkr_webhook_info(webhook_payload).deliver_later
      end
    when 'invitation.deleted'
      new_hire = get_candidate_info(webhook_payload)
      if new_hire
        new_hire.update(checkr_status: "Cancelled", checkr_result: "Cancelled")
      else
        CheckrMailer.checkr_webhook_info(webhook_payload).deliver_later
      end
    when 'invitation.expired'
      new_hire = get_candidate_info(webhook_payload)
      if new_hire
        new_hire.update(checkr_status: "Expired", checkr_result: "Expired")
      else
        CheckrMailer.checkr_webhook_info(webhook_payload).deliver_later
      end
    when 'verification.created'
      new_hire = get_candidate_info(webhook_payload)
      if new_hire
        new_hire.update(checkr_status: "Verification Requested", checkr_result: "Verification Requested")
      else
        CheckrMailer.checkr_webhook_info(webhook_payload).deliver_later
      end
    when 'verification.completed'
      new_hire = get_candidate_info(webhook_payload)
      if new_hire
        new_hire.update(checkr_status: "Verification Submitted", checkr_result: "Verification Submitted")
      else
        CheckrMailer.checkr_webhook_info(webhook_payload).deliver_later
      end
    when 'verification.processed'
      new_hire = get_candidate_info(webhook_payload)
      if new_hire
        new_hire.update(checkr_status: "Verification Processed", checkr_result: "Verification Processed")
      else
        CheckrMailer.checkr_webhook_info(webhook_payload).deliver_later
      end
    when 'report.created'
      new_hire = get_candidate_info(webhook_payload)
      if new_hire
        new_hire.update(checkr_status: "Report Created", checkr_result: "Pending")
      else
        CheckrMailer.checkr_webhook_info(webhook_payload).deliver_later
      end
    when 'report.updated'
      new_hire = get_candidate_info(webhook_payload)
      if new_hire
        new_hire.update(checkr_status: "Report Updated", checkr_result: "Pending")
      else
        CheckrMailer.checkr_webhook_info(webhook_payload).deliver_later
      end
    when 'report.cancelled'
      new_hire = get_candidate_info(webhook_payload)
      if new_hire
        new_hire.update(checkr_status: "Report Cancelled", checkr_result: "Cancelled")
      else
        CheckrMailer.checkr_webhook_info(webhook_payload).deliver_later
      end
    when 'report.suspended'
      new_hire = get_candidate_info(webhook_payload)
      if new_hire
        new_hire.update(checkr_status: "Report Suspended", checkr_result: "Suspended")
      else
        CheckrMailer.checkr_webhook_info(webhook_payload).deliver_later
      end
    when 'report.resumed'
      new_hire = get_candidate_info(webhook_payload)
      if new_hire
        new_hire.update(checkr_status: "Report Resumed", checkr_result: "Pending")
      else
        CheckrMailer.checkr_webhook_info(webhook_payload).deliver_later
      end
    when 'report.disputed'
      new_hire = get_candidate_info(webhook_payload)
      if new_hire
        new_hire.update(checkr_status: "Report Disputed", checkr_result: "In Dispute")
      else
        CheckrMailer.checkr_webhook_info(webhook_payload).deliver_later
      end
    when 'report.pre_adverse_action'

    when 'report.post_adverse_action'

    when 'report.engaged'

    when 'adverse_action.notice_not_delivered'

    when 'report.completed'
      new_hire = get_candidate_info(webhook_payload)
      if new_hire
        type = webhook_payload[:data][:object][:package]
        if type == "goodhire_extended_criminal_package_national_criminal_unlimited_county"
          user = "employee"
        else
          user = "newhire"
        end
        if webhook_payload[:data][:object][:result] == "clear"
          if user == "newhire"
            new_hire.update(checkr_status: "report completed", background_received: true, background_ok: true, checkr_result: "Approved")
            SendNewHireBackgroundSmsJob.perform_later(new_hire, "#{new_hire.full_name} at #{new_hire.store.number} background check was approved")
            if new_hire.food_handler == false
              AssignClassJob.perform_later(new_hire.id, "newhire", new_hire.user.id)
            end
          else
            new_hire.update(checkr_status: "report completed", checkr_result: "Approved")
            SendNewHireBackgroundSmsJob.perform_later(new_hire, "#{new_hire.full_name} at #{new_hire.stores[0].number} background check was approved")
          end
        else
          new_hire.update(checkr_status: "report completed", background_received: true, checkr_result: "Needs Review")
        end
      else
        CheckrMailer.checkr_webhook_info(webhook_payload).deliver_later
      end
    else
      CheckrMailer.checkr_webhook_info(webhook_payload).deliver_later
    end
    inbound_webhook.update(status: :processed)
    # TODO:add cron job to clean up database of webhooks older than 30 days marked as
    # :processed
  end

  def get_candidate(payload)
    if payload[:data][:object][:metadata][:type] == "newhire"
      NewHire.find(payload[:data][:object][:custom_id])
    else
      User.find(payload[:data][:object][:custom_id])
    end
  end

  def get_candidate_info(payload)
    new_hire = NewHire.find_by(checkr_id: payload[:data][:object][:candidate_id])
    unless new_hire
      new_hire = User.find_by(checkr_id: payload[:data][:object][:candidate_id])
    end
    new_hire
  end

end

