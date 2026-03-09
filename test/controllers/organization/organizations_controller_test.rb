require "test_helper"

class Organization::OrganizationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @organization = organizations(:one)
    @user = users(:one) # associated with organizations(:one) in fixtures usually
    @other_organization = organizations(:two)
    @user.update!(organization: @organization)
  end

  test "should show organization when associated" do
    sign_in @user
    get organization_organization_url(@organization)
    assert_response :success
  end

  test "should redirect when not associated" do
    sign_in @user
    get organization_organization_url(@other_organization)
    assert_redirected_to root_path
    assert_equal "You are not authorized to view this organization's details.", flash[:alert]
  end

  test "should redirect to login when not signed in" do
    get organization_organization_url(@organization)
    assert_redirected_to new_user_session_path
  end
end
