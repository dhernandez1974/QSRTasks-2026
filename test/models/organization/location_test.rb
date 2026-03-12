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

  test "should return manager users" do
    org = organizations(:one)
    # Using existing department or creating a new one if not available via fixture
    dept = Organization::Department.first || Organization::Department.create!(name: "Ops", organization: org, updated_by: @user)
    pos_gm = Organization::Position.find_or_create_by!(name: "General Manager", organization: org, department: dept) do |p|
      p.updated_by = @user
    end
    gm_user = User.create!(email: "gm@example.com", password: "password", first_name: "GM", last_name: "User", position: pos_gm, organization: org)
    @location.users << gm_user

    assert_equal gm_user, @location.general_manager
    assert_nil @location.supervisor
    assert_nil @location.operations_manager
  end

  test "should return users grouped by position" do
    org = organizations(:one)
    dept = Organization::Department.create!(name: "Operations", organization: org, updated_by: @user)

    pos_gm = Organization::Position.create!(name: "General Manager", organization: org, department: dept, updated_by: @user)
    pos_crew = Organization::Position.create!(name: "Crew", organization: org, department: dept, updated_by: @user)

    user1 = User.create!(email: "user1@example.com", password: "password", first_name: "GM", last_name: "User", position: pos_gm, organization: org)
    user2 = User.create!(email: "user2@example.com", password: "password", first_name: "Crew", last_name: "User", position: pos_crew, organization: org)

    @location.users << user1
    @location.users << user2

    grouped_users = @location.users.includes(:position).group_by(&:position)

    assert_includes grouped_users.keys, pos_gm
    assert_includes grouped_users.keys, pos_crew
    assert_includes grouped_users[pos_gm], user1
    assert_includes grouped_users[pos_crew], user2
  end
end
