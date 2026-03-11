require "test_helper"

class NormalizationTest < ActiveSupport::TestCase
  test "organization normalization" do
    org = Organization.create!(
      name: "the best organization",
      phone: "1234567890",
      eid: "ABC-123",
      secondary_eids: ["XYZ-789", "  "],
      street: "St", city: "City", state: "ST", zip: "12345"
    )
    assert_equal "The Best Organization", org.name
    assert_equal "123-456-7890", org.phone
    assert_equal "abc-123", org.eid
    assert_equal ["xyz-789"], org.secondary_eids
  end

  test "location normalization" do
    org = organizations(:one)
    loc = Organization::Location.create!(
      name: "Test Location",
      number: "101",
      street: "St", city: "City", state: "ST", zip: "12345",
      phone: "9876543210",
      email: "LOCATION@EXAMPLE.COM",
      organization: org,
      safe_count: 1,
      headset_count: 1
    )
    assert_equal "987-654-3210", loc.phone
    assert_equal "location@example.com", loc.email
  end

  test "user normalization" do
    user = User.create!(
      email: "USER@EXAMPLE.COM",
      password: "password",
      first_name: "john doe",
      last_name: "smith jr",
      phone_number: "5551234567",
      confirmed_at: Time.now
    )
    assert_equal "user@example.com", user.email
    assert_equal "John Doe", user.first_name
    assert_equal "Smith Jr", user.last_name
    assert_equal "555-123-4567", user.phone_number
  end

  test "admin normalization" do
    admin = Admin.create!(
      email: "ADMIN@EXAMPLE.COM",
      password: "password",
      first_name: "jane doe",
      last_name: "van der graph",
      confirmed_at: Time.now
    )
    assert_equal "admin@example.com", admin.email
    assert_equal "Jane Doe", admin.first_name
    assert_equal "Van Der Graph", admin.last_name
  end

  test "hr_ssn normalization and association" do
    org = organizations(:one)
    hr_ssn = Datapass::HrSsn.create!(
      geid: "GEID-123",
      ssn: "123456789",
      organization: org
    )
    assert_equal "geid-123", hr_ssn.geid
    assert_equal org, hr_ssn.organization
  end
end
