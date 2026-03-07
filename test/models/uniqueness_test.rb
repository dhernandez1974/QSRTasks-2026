require "test_helper"

class UniquenessTest < ActiveSupport::TestCase
  setup do
    @org = organizations(:one)
    @user = users(:one)
    @admin = admins(:one)
    @location = locations(:one)
  end

  test "user email must be unique" do
    duplicate_user = User.new(email: @user.email, password: "password")
    assert_not duplicate_user.valid?
    assert_includes duplicate_user.errors[:email], "has already been taken"
  end

  test "admin email must be unique" do
    duplicate_admin = Admin.new(email: @admin.email, password: "password")
    assert_not duplicate_admin.valid?
    assert_includes duplicate_admin.errors[:email], "has already been taken"
  end

  test "location email must be unique" do
    duplicate_location = Location.new(
      name: "Duplicate",
      number: "999",
      street: "St", city: "City", state: "ST", zip: "12345",
      phone: "1112223333",
      email: @location.email,
      organization: @org,
      safe_count: 1,
      headset_count: 1
    )
    assert_not duplicate_location.valid?
    assert_includes duplicate_location.errors[:email], "has already been taken"
  end

  test "location phone must be unique" do
    duplicate_location = Location.new(
      name: "Duplicate",
      number: "999",
      street: "St", city: "City", state: "ST", zip: "12345",
      phone: @location.phone,
      email: "unique@example.com",
      organization: @org,
      safe_count: 1,
      headset_count: 1
    )
    assert_not duplicate_location.valid?
    assert_includes duplicate_location.errors[:phone], "has already been taken"
  end

  test "user phone_number must be unique" do
    @user.update!(phone_number: "1234567890")
    duplicate_user = User.new(email: "unique@example.com", password: "password", phone_number: "123-456-7890")
    assert_not duplicate_user.valid?
    assert_includes duplicate_user.errors[:phone_number], "has already been taken"
  end

  test "uniqueness is case insensitive for emails" do
    duplicate_location = Location.new(
      name: "Duplicate",
      number: "999",
      street: "St", city: "City", state: "ST", zip: "12345",
      phone: "1112223333",
      email: @location.email.upcase,
      organization: @org,
      safe_count: 1,
      headset_count: 1
    )
    assert_not duplicate_location.valid?
    assert_includes duplicate_location.errors[:email], "has already been taken"
  end
end
