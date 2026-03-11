require "test_helper"

class Organization::PositionTest < ActiveSupport::TestCase
  test "reports_to association" do
    org = Organization.first || Organization.create!(name: "Test Org", phone: "1234567890", eid: "test", street: "123 Main St", city: "City", state: "ST", zip: "12345")
    user = User.first || User.create!(email: "test@example.com", password: "password", organization: org)
    dept = Organization::Department.create!(name: "Test Dept", organization: org, updated_by: user)
    pos = Organization::Position.create!(
      name: "Test Position",
      organization: org,
      department: dept,
      reports_to: dept,
      updated_by: user,
      rate_type: "Salary",
      authorized: Organization::Position::AUTHORIZED,
      authorization_level: "Location",
      job_tier: "Restaurant",
      job_class: "Management"
    )

    assert_equal dept, pos.reports_to
    assert_instance_of Organization::Department, pos.reports_to
  end
end
