class Webhooks::DatapassController < Webhooks::BaseController
  # Ensure verify_event is called before the create action
  # (Already inherited from Webhooks::BaseController)

  def create
    # Use the 'payload' helper method from BaseController to avoid re-reading the stream
    record = InboundWebhook.create!(body: payload)

    # Offload processing to background job with correct naming convention
    DatapassWebhookRouterJob.perform_later(record, request.content_type)

    head :ok
  end

  private

    def verify_event
      token = request.headers['x-auth-token']
      expected_token = Rails.application.credentials.dig(:perpetual_token, :dp_token)

      # Use secure_compare to prevent timing attacks
      unless token.present? && ActiveSupport::SecurityUtils.secure_compare(token, expected_token)
        render json: { error: 'Unauthorized' }, status: :unauthorized
      end
    end
end