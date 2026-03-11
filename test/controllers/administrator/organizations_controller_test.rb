require "test_helper"

class Administrator::OrganizationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @organization = organizations(:one)
    @user = users(:one)
    @admin = admins(:one)
    sign_in @admin
  end

  test "should get index" do
    get administrator_organizations_url
    assert_response :success
  end

  test "should get new" do
    get new_administrator_organization_url
    assert_response :success
  end

  test "should create organization" do
    assert_difference("Organization.count") do
      assert_difference("User.count") do
        post administrator_organizations_url, params: { 
          organization: { 
            city: "City", eid: "EID", name: "Org", phone: "123", state: "ST", street: "St", zip: "12345" 
          },
          user: {
            email: "new_user@example.com",
            password: "password",
            password_confirmation: "password"
          }
        }
      end
    end

    assert_redirected_to administrator_organization_url(Organization.order(created_at: :asc).last)
  end

  test "should show organization" do
    get administrator_organization_url(@organization)
    assert_response :success
  end

  test "should get edit" do
    get edit_administrator_organization_url(@organization)
    assert_response :success
  end

  test "should update organization" do
    patch administrator_organization_url(@organization), params: { 
      organization: { name: "Updated Name" },
      user: { email: @user.email } # Keep same email or update it
    }
    assert_redirected_to administrator_organization_url(@organization)
    @organization.reload
    assert_equal "Updated Name", @organization.name
  end

  test "should destroy organization" do
    assert_difference("Organization.count", -1) do
      delete administrator_organization_url(@organization)
    end

    assert_redirected_to administrator_organizations_url
  end

  test "should sync user info" do
    assert_enqueued_with(job: Datapass::OrganizationUserInfoJob) do
      post sync_user_info_administrator_organization_url(@organization)
    end
    assert_redirected_to administrator_organization_url(@organization)
    assert_equal "Organization user info sync job has been started.", flash[:notice]
  end

  test "should sync user info with secondary organizations" do
    @organization.update!(secondary_eids: ["secondary-eid"])
    secondary_org = organizations(:two)
    secondary_org.update!(eid: "secondary-eid")

    assert_enqueued_with(job: Datapass::OrganizationUserInfoJob, args: [{ organization_ids: [@organization.id, secondary_org.id] }]) do
      post sync_user_info_administrator_organization_url(@organization)
    end
  end

  test "should redirect to admin login when not signed in" do
    sign_out @admin
    get administrator_organizations_url
    assert_redirected_to new_admin_session_path
  end

  test "should redirect to admin login when signed in as user" do
    sign_out @admin
    sign_in @user
    get administrator_organizations_url
    assert_redirected_to new_admin_session_path
  end
end
