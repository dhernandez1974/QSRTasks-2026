class UpdateNewHireJob < ApplicationJob
  queue_as :default

  def perform(nh, checkr_status, checkr_id, checkr_url)
    new_hire = NewHire.find(nh)
    if new_hire.update(checkr_status: checkr_status, checkr_id: checkr_id, bcgd_url: checkr_url)
      CheckrMailer.update_nh_email(new_hire, "Passed", checkr_status, checkr_id, checkr_url).deliver_later
    else
      CheckrMailer.update_nh_email(new_hire, "Failed", checkr_status, checkr_id, checkr_url).deliver_later
    end
  end
end
