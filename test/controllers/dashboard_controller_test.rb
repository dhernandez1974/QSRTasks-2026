require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "should get admin when signed in as admin" do
    sign_in admins(:one)
    get admin_dashboard_url
    assert_response :success
  end

  test "should redirect admin when not signed in" do
    get admin_dashboard_url
    assert_redirected_to new_admin_session_path
  end

  test "should get user when signed in as user" do
    sign_in users(:one)
    get user_dashboard_url
    assert_response :success
  end

  test "should redirect user when not signed in" do
    get user_dashboard_url
    assert_redirected_to new_user_session_path
  end

  test "should get applicant" do
    get applicant_dashboard_url
    assert_response :success
  end
end
