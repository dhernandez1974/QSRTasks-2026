require "test_helper"

class Webhooks::DatapassControllerTest < ActionDispatch::IntegrationTest
  setup do
    @dp_token = Rails.application.credentials.dig(:perpetual_token, :dp_token)
  end

  test "should create inbound webhook and return ok with valid token" do
    payload = { filename: "1234567_datasource_topic_id_v1_20260307135316000_eid.csv.enc" }.to_json
    
    assert_difference("InboundWebhook.count") do
      post webhooks_datapass_url, 
           params: payload, 
           headers: { "x-auth-token": @dp_token, "Content-Type": "application/json" }
    end

    assert_response :ok
  end

  test "should return unauthorized with invalid token" do
    post webhooks_datapass_url, 
         params: { foo: "bar" }.to_json, 
         headers: { "x-auth-token": "invalid_token", "Content-Type": "application/json" }

    assert_response :unauthorized
  end

  test "should return unauthorized with missing token" do
    post webhooks_datapass_url, 
         params: { foo: "bar" }.to_json, 
         headers: { "Content-Type": "application/json" }

    assert_response :unauthorized
  end
end
