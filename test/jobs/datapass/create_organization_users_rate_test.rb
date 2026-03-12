require "test_helper"

class Datapass::CreateOrganizationUsersRateTest < ActiveJob::TestCase
  setup do
    @organization = organizations(:one)
    @organization.update!(eid: "EID123")
    
    User.delete_all
    Datapass::EmployeeDetail.delete_all
    Datapass::EmployeeHistory.delete_all

    @location = organization_locations(:one)
    @geid = "rate_geid_123"
  end

  test "should assign rate to user from employee history" do
    jtc_code = "JTC123"
    
    # Create Employee Detail to ensure user is picked up
    Datapass::EmployeeDetail.create!(
      geid: @geid,
      first_name: "Rate",
      last_name: "User",
      organization: @organization,
      location: @location,
      eid: "EID123",
      jtc: jtc_code
    )

    # Create Employee History with repeating_full_jtc_history
    # Search this attribute and use the PayRate for the user's position's jtc 
    # with a Type = "P" with an EndDate of null.
    history_data = [
      { "Jtc" => "OTHER", "PayRate" => 10.0, "Type" => "P", "EndDate" => nil },
      { "Jtc" => jtc_code, "PayRate" => 15.5, "Type" => "O", "EndDate" => nil }, # Wrong Type
      { "Jtc" => jtc_code, "PayRate" => 12.0, "Type" => "P", "EndDate" => "2026-01-01" }, # Has EndDate
      { "Jtc" => jtc_code, "PayRate" => 18.75, "Type" => "P", "EndDate" => nil } # Correct one
    ]

    Datapass::EmployeeHistory.create!(
      geid: @geid,
      organization: @organization,
      location: @location,
      repeating_full_jtc_history: history_data
    )

    Datapass::CreateOrganizationUsersJob.perform_now(@organization.id)

    user = User.find_by(geid: @geid)
    assert_not_nil user
    assert_equal 18.75, user.rate
  end

  test "should not assign rate if JTC does not match" do
    # Create Employee Detail with different JTC
    Datapass::EmployeeDetail.create!(
      geid: @geid,
      first_name: "Rate",
      last_name: "User",
      organization: @organization,
      location: @location,
      eid: "EID123",
      jtc: "OTHER_JTC"
    )

    history_data = [
      { "Jtc" => "JTC123", "PayRate" => 18.75, "Type" => "P", "EndDate" => nil }
    ]

    Datapass::EmployeeHistory.create!(
      geid: @geid,
      organization: @organization,
      location: @location,
      repeating_full_jtc_history: history_data
    )

    Datapass::CreateOrganizationUsersJob.perform_now(@organization.id)

    user = User.find_by(geid: @geid)
    assert_nil user.rate
  end

  test "should not assign rate if Type is not P" do
    jtc_code = "JTC123"
    Datapass::EmployeeDetail.create!(
      geid: @geid,
      organization: @organization,
      location: @location,
      eid: "EID123",
      jtc: jtc_code
    )

    history_data = [
      { "Jtc" => jtc_code, "PayRate" => 18.75, "Type" => "A", "EndDate" => nil }
    ]

    Datapass::EmployeeHistory.create!(
      geid: @geid,
      organization: @organization,
      location: @location,
      repeating_full_jtc_history: history_data
    )

    Datapass::CreateOrganizationUsersJob.perform_now(@organization.id)

    user = User.find_by(geid: @geid)
    assert_nil user.rate
  end

  test "should not assign rate if EndDate is present" do
    jtc_code = "JTC123"
    Datapass::EmployeeDetail.create!(
      geid: @geid,
      organization: @organization,
      location: @location,
      eid: "EID123",
      jtc: jtc_code
    )

    history_data = [
      { "Jtc" => jtc_code, "PayRate" => 18.75, "Type" => "P", "EndDate" => "2026-03-12" }
    ]

    Datapass::EmployeeHistory.create!(
      geid: @geid,
      organization: @organization,
      location: @location,
      repeating_full_jtc_history: history_data
    )

    Datapass::CreateOrganizationUsersJob.perform_now(@organization.id)

    user = User.find_by(geid: @geid)
    assert_nil user.rate
  end
end
