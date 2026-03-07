require "test_helper"

class OrganizationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @organization = organizations(:one)
    @user = users(:one)
    @admin = admins(:one)
    sign_in @admin
  end

  test "should get index" do
    get organizations_url
    assert_response :success
  end

  test "should get new" do
    get new_organization_url
    assert_response :success
  end

  test "should create organization" do
    assert_difference("Organization.count") do
      assert_difference("User.count") do
        post organizations_url, params: { 
          organization: { 
            city: "City", eid: "EID", name: "Org", phone: "123", state: "ST", street: "St", zip: "12345", primary_operator: true 
          },
          user: {
            email: "new_user@example.com",
            password: "password",
            password_confirmation: "password"
          }
        }
      end
    end

    assert_redirected_to organization_url(Organization.order(created_at: :asc).last)
  end

  test "should show organization" do
    get organization_url(@organization)
    assert_response :success
  end

  test "should get edit" do
    get edit_organization_url(@organization)
    assert_response :success
  end

  test "should update organization" do
    patch organization_url(@organization), params: { 
      organization: { name: "Updated Name" },
      user: { email: @user.email } # Keep same email or update it
    }
    assert_redirected_to organization_url(@organization)
    @organization.reload
    assert_equal "Updated Name", @organization.name
  end

  test "should destroy organization" do
    assert_difference("Organization.count", -1) do
      delete organization_url(@organization)
    end

    assert_redirected_to organizations_url
  end

  test "should redirect to admin login when not signed in" do
    sign_out @admin
    get organizations_url
    assert_redirected_to new_admin_session_path
  end

  test "should redirect to admin login when signed in as user" do
    sign_out @admin
    sign_in @user
    get organizations_url
    assert_redirected_to new_admin_session_path
  end
end
