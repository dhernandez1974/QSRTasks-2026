require "test_helper"

class LocationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @location = locations(:one)
    @admin = admins(:one)
    sign_in @admin
  end

  test "should get index" do
    get locations_url
    assert_response :success
  end

  test "should get new" do
    get new_location_url
    assert_response :success
  end

  test "should create location" do
    assert_difference("Location.count") do
      post locations_url, params: { location: { city: @location.city, email: @location.email, headset_count: @location.headset_count, ipad_count: @location.ipad_count, location_type: @location.location_type, name: @location.name, number: @location.number, organization_id: @location.organization_id, phone: @location.phone, safe_count: @location.safe_count, state: @location.state, street: @location.street, zip: @location.zip } }
    end
    
    assert_redirected_to location_url(Location.last)
  end

  test "should show location" do
    get location_url(@location)
    assert_response :success
  end

  test "should get edit" do
    get edit_location_url(@location)
    assert_response :success
  end

  test "should update location" do
    patch location_url(@location), params: { location: { city: @location.city, email: @location.email, headset_count: @location.headset_count, ipad_count: @location.ipad_count, location_type: @location.location_type, name: @location.name, number: @location.number, organization_id: @location.organization_id, phone: @location.phone, safe_count: @location.safe_count, state: @location.state, street: @location.street, zip: @location.zip } }
    assert_redirected_to location_url(@location)
  end

  test "should destroy location" do
    assert_difference("Location.count", -1) do
      delete location_url(@location)
    end

    assert_redirected_to locations_url
  end
end
