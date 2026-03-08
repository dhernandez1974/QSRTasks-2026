require "test_helper"

class Organization::LocationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @location = organization_locations(:one)
    @admin = admins(:one)
    sign_in @admin
  end

  test "should get index" do
    get organization_locations_url
    assert_response :success
  end

  test "should get new" do
    get new_organization_location_url
    assert_response :success
  end

  test "should create location" do
    assert_difference("Organization::Location.count") do
      post organization_locations_url, params: { location: { city: @location.city, email: "new_location@example.com", headset_count: @location.headset_count, ipad_count: @location.ipad_count, location_type: @location.location_type, name: @location.name, number: "9999", organization_id: @location.organization_id, phone: "555-555-5555", safe_count: @location.safe_count, state: @location.state, street: @location.street, zip: @location.zip } }
    end
    
    assert_redirected_to organization_location_url(Organization::Location.order(created_at: :asc).last)
  end

  test "should show location" do
    get organization_location_url(@location)
    assert_response :success
  end

  test "should get edit" do
    get edit_organization_location_url(@location)
    assert_response :success
  end

  test "should update location" do
    patch organization_location_url(@location), params: { location: { city: @location.city, email: @location.email, headset_count: @location.headset_count, ipad_count: @location.ipad_count, location_type: @location.location_type, name: @location.name, number: @location.number, organization_id: @location.organization_id, phone: @location.phone, safe_count: @location.safe_count, state: @location.state, street: @location.street, zip: @location.zip } }
    assert_redirected_to organization_location_url(@location)
  end

  test "should destroy location" do
    assert_difference("Organization::Location.count", -1) do
      delete organization_location_url(@location)
    end

    assert_redirected_to organization_locations_url
  end
end
