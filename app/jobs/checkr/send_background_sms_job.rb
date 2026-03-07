class SendBackgroundSmsJob < ApplicationJob
  queue_as :default

  def perform(new_hire, message)
    if Phonelib.valid?(new_hire.phone)
      TwilioClient.new.send_text(new_hire, message)
    end
  end
end
