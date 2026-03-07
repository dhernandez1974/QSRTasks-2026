class Webhooks::DatapassTestController < Webhooks::BaseController

  def create
    content_type = request.content_type
    record = InboundWebhook.create!(body: payload)
    #DatapassTestWebhookRouter.perform_later(record, content_type)
    head :ok
  end

  private

    def verify_event
      token = request.headers['x-auth-token']
      expected_token = Rails.application.credentials.dig(:perpetual_token, :test_dp_token)
      unless token && ActiveSupport::SecurityUtils.secure_compare(token, expected_token)
        render json: { error: 'Unauthorized' }, status: :unauthorized
        return
      end
      puts "AUTHENTICATED TOKEN"
    end

end