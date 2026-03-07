class Webhooks::FullscheduleController < Webhooks::BaseController
  def create
    record = InboundWebhook.create!(body: payload)
    FullscheduleWebhookRouter.perform_later(record)
    head :ok
  end

  private

    def verify_event
      true
    end

end