require "test_helper"

class UserPolicyTest < ActiveSupport::TestCase
  setup do
    @organization = organizations(:one)
    # Get a department name that exists
    @department = Organization::Department.create!(name: "Test Dept", organization: @organization)
    @authorized_json = Organization::Position::AUTHORIZED.deep_dup
    # Give list and show access
    @authorized_json[:user][:list][:access] = true
    @authorized_json[:user][:show][:access] = true

    @position = Organization::Position.create!(
      name: "Test Manager",
      organization: @organization,
      department: @department,
      authorized: @authorized_json
    )
    @user = User.create!(
      email: "manager@example.com",
      password: "password",
      position: @position,
      organization: @organization
    )
  end

  test "user can list users if authorized" do
    policy = UserPolicy.new(@user, User)
    assert policy.index?
  end

  test "user cannot delete users if not authorized" do
    policy = UserPolicy.new(@user, User)
    assert_not policy.destroy?
  end

  test "user scope handles organization level list" do
    @authorized_json[:user][:list][:organization] = true
    @position.update!(authorized: @authorized_json)
    
    scope = UserPolicy::Scope.new(@user, User.all).resolve
    assert_equal @organization.users.count, scope.count
  end

  test "admin user has access to everything regardless of position" do
    @position.update!(authorized: {})
    @user.update!(admin: true)
    
    policy = UserPolicy.new(@user, User)
    assert policy.index?
    assert policy.show?
    assert policy.create?
    assert policy.update?
    assert policy.destroy?
  end
end
