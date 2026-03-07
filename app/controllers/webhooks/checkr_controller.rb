class Webhooks::CheckrController < Webhooks::BaseController

  def create
    record = InboundWebhook.create!(body: payload)
    CheckrWebhookRouter.perform_later(record)
    head :ok
  end

  private

    def verify_event
      signature = request.headers['HTTP_X_CHECKR_SIGNATURE']
      digest  = OpenSSL::Digest.new('sha256')
      computed_hash = OpenSSL::HMAC.hexdigest(digest, Rails.application.credentials.dig(:checkr, :api), payload)
      OpenSSL.secure_compare(signature, computed_hash)
    end

end