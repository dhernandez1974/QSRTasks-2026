require "test_helper"

class Datapass::HrSsnTest < ActiveSupport::TestCase
  test "fixture loading" do
    assert_not_nil datapass_hr_ssns(:one)
    assert_equal "MyString", datapass_hr_ssns(:one).geid
  end
end
