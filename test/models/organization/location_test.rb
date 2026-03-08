require "test_helper"

class Organization::LocationTest < ActiveSupport::TestCase
  setup do
    @location = organization_locations(:one)
    @user = users(:one)
  end

  test "should belong to organization" do
    assert_respond_to @location, :organization
  end

  test "should have many users" do
    assert_respond_to @location, :users
  end

  test "should have and belong to many users" do
    # This checks if the HABTM association is correctly set up
    assert @user.respond_to?(:locations)
    assert @location.respond_to?(:users)
  end
end
