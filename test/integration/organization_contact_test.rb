require "test_helper"

class OrganizationContactTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = admins(:one)
    sign_in @admin
  end

  test "should set created user as admin and associate as contact" do
    assert_difference("Organization.count", 1) do
      assert_difference("User.count", 1) do
        post administrator_organizations_url, params: { 
          organization: { 
            city: "Test City", eid: "TESTEID", name: "Test Org", phone: "1234567890", state: "NY", street: "123 Main St", zip: "10001", primary_operator: true 
          },
          user: {
            email: "contact@example.com",
            password: "password123",
            password_confirmation: "password123"
          }
        }
      end
    end

    org = Organization.find_by(eid: "testeid")
    user = User.find_by(email: "contact@example.com")

    assert_not_nil org
    assert_not_nil user
    assert_equal org.id, user.organization_id
    assert_equal true, user.admin, "User should be an admin"
    assert_equal user, org.contact, "User should be the organization contact"
  end

  test "contact should persist even after more users are added" do
    org = Organization.create!(
      city: "Test City", eid: "TESTPERSIST", name: "Test Org", phone: "1234567890", state: "NY", street: "123 Main St", zip: "10001", primary_operator: true
    )
    contact_user = User.new(
      email: "admin_contact@example.com",
      password: "password123",
      organization: org,
      admin: true
    )
    contact_user.skip_confirmation!
    contact_user.save!

    assert_not_nil User.find_by(email: "admin_contact@example.com", admin: true)
    assert_equal org.id, contact_user.organization_id
    assert_equal contact_user, org.reload.contact

    # Add a regular user
    regular_user = User.new(
      email: "regular@example.com",
      password: "password123",
      organization: org,
      admin: false
    )
    regular_user.skip_confirmation!
    regular_user.save!

    assert_equal contact_user, org.reload.contact, "Contact should still be the admin user"
  end
end
