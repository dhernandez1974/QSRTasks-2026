require "test_helper"

class OrganizationTest < ActiveSupport::TestCase
  test "should be valid with all required attributes" do
    organization = Organization.new(
      name: "Org",
      phone: "123",
      eid: "EID",
      street: "St",
      city: "City",
      state: "ST",
      zip: "12345"
    )
    assert organization.valid?
  end

  test "should be invalid without name" do
    organization = Organization.new(name: nil)
    assert_not organization.valid?
    assert_includes organization.errors[:name], "can't be blank"
  end

  test "should be invalid without phone" do
    organization = Organization.new(phone: nil)
    assert_not organization.valid?
    assert_includes organization.errors[:phone], "can't be blank"
  end

  test "should be invalid without eid" do
    organization = Organization.new(eid: nil)
    assert_not organization.valid?
    assert_includes organization.errors[:eid], "can't be blank"
  end

  test "should be invalid without street" do
    organization = Organization.new(street: nil)
    assert_not organization.valid?
    assert_includes organization.errors[:street], "can't be blank"
  end

  test "should be invalid without city" do
    organization = Organization.new(city: nil)
    assert_not organization.valid?
    assert_includes organization.errors[:city], "can't be blank"
  end

  test "should be invalid without state" do
    organization = Organization.new(state: nil)
    assert_not organization.valid?
    assert_includes organization.errors[:state], "can't be blank"
  end

  test "should be invalid without zip" do
    organization = Organization.new(zip: nil)
    assert_not organization.valid?
    assert_includes organization.errors[:zip], "can't be blank"
  end
  test "eid should be encrypted in the database" do
    organization = Organization.create!(
      name: "Org",
      phone: "123",
      eid: "SECRET_EID",
      street: "St",
      city: "City",
      state: "ST",
      zip: "12345"
    )
    
    # Check that transparent access works
    assert_equal "secret_eid", organization.reload.eid
    
    # Check the raw value in the database
    raw_eid = Organization.connection.select_value("SELECT eid FROM organizations WHERE id = '#{organization.id}'")
    assert_not_equal "SECRET_EID", raw_eid
    # Rails encryption adds a header and it's base64 encoded by default
    assert raw_eid.start_with?("{\"p\":") || raw_eid.start_with?("{")
  end

  test "eid should be searchable using find_by" do
    Organization.create!(
      name: "Searchable Org",
      phone: "123",
      eid: "UNIQUE_EID",
      street: "St",
      city: "City",
      state: "ST",
      zip: "12345"
    )
    
    found_org = Organization.find_by(eid: "unique_eid")
    assert_not_nil found_org
    assert_equal "Searchable Org", found_org.name
  end

  test "set_default_departments should create departments and positions if user is present" do
    org = Organization.new(
      name: "Test Org", phone: "1234567890", eid: "test_eid",
      street: "123 St", city: "City", state: "ST", zip: "12345"
    )
    user = User.new(
      first_name: "Test", last_name: "User", email: "test@example.com",
      password: "password123", organization: org
    )
    
    # Manually calling set_default_departments as it's called after_create
    # but self.contact might be nil if not saved yet.
    org.save!
    user.save!
    
    org.set_default_departments
    
    assert_equal 3, org.departments.count
    assert_equal 9, org.positions.count
    assert_equal user, org.departments.first.updated_by
  end
end
