require "test_helper"

class UserAdminAttributeTest < ActiveSupport::TestCase
  test "new user should have admin default to false" do
    user = User.new(email: "test_admin@example.com", password: "password")
    assert_not user.admin?, "admin should default to false"
  end

  test "admin attribute can be set to true" do
    user = User.new(email: "test_admin_true@example.com", password: "password", admin: true)
    assert user.admin?, "admin should be true when set"
  end

  test "user can be saved with admin: true" do
    user = User.create!(email: "saved_admin@example.com", password: "password", admin: true, confirmed_at: Time.now)
    assert user.reload.admin?, "saved user should retain admin: true"
  end
end
