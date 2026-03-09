require "test_helper"

class Datapass::CreateOrganizationUsersTerminationTest < ActiveJob::TestCase
  setup do
    @organization = organizations(:one)
    @organization.update!(eid: "TERM_EID")
    
    # Clear other possible matches
    Datapass::EmployeeDetail.where(eid: "TERM_EID").delete_all
    Datapass::HrPersonal.where(organization_id: @organization.id).delete_all
    Datapass::HrSsn.where(organization_id: @organization.id).delete_all
    Datapass::Idmgmt.where(organization_id: @organization.id).delete_all
    Datapass::Identification.where(organization_id: @organization.id).delete_all
    Datapass::EmployeeHistory.where(organization_id: @organization.id).delete_all

    @location = organization_locations(:one)
    @active_geid = "active_user_123"
    @terminated_geid = "terminated_user_456"
  end

  test "should create users if termination_code is nil, empty, or 'A'" do
    # nil termination_code
    Datapass::EmployeeDetail.create!(
      geid: "nil_code_geid",
      first_name: "Nil", last_name: "Code", email: "nil@example.com",
      organization: @organization, location: @location, eid: "TERM_EID"
    )

    # empty termination_code (empty string)
    Datapass::EmployeeDetail.create!(
      geid: "empty_code_geid",
      first_name: "Empty", last_name: "Code", email: "empty@example.com",
      organization: @organization, location: @location, eid: "TERM_EID"
    )
    Datapass::EmployeeHistory.create!(
      geid: "empty_code_geid", organization: @organization, location: @location,
      termination_code: ""
    )

    # 'A' termination_code
    Datapass::EmployeeDetail.create!(
      geid: "a_code_geid",
      first_name: "A", last_name: "Code", email: "a@example.com",
      organization: @organization, location: @location, eid: "TERM_EID"
    )
    Datapass::EmployeeHistory.create!(
      geid: "a_code_geid", organization: @organization, location: @location,
      termination_code: "A"
    )

    # 'T' termination_code (should NOT create user)
    Datapass::EmployeeDetail.create!(
      geid: "t_code_geid",
      first_name: "T", last_name: "Code", email: "t@example.com",
      organization: @organization, location: @location, eid: "TERM_EID"
    )
    Datapass::EmployeeHistory.create!(
      geid: "t_code_geid", organization: @organization, location: @location,
      termination_code: "T"
    )

    # Expect 3 users to be created (nil, empty, and 'A')
    assert_difference "User.count", 3 do
      Datapass::CreateOrganizationUsersJob.perform_now(@organization.id)
    end

    assert User.exists?(geid: "nil_code_geid")
    assert User.exists?(geid: "empty_code_geid")
    assert User.exists?(geid: "a_code_geid")
    assert_not User.exists?(geid: "t_code_geid")
  end

  test "should use the most recent history record to determine termination" do
    # User with history 'A' then 'T'
    Datapass::EmployeeDetail.create!(
      geid: "recent_t_geid",
      first_name: "Recent", last_name: "T", email: "recent_t@example.com",
      organization: @organization, location: @location, eid: "TERM_EID"
    )
    Datapass::EmployeeHistory.create!(
      geid: "recent_t_geid", organization: @organization, location: @location,
      termination_code: "A", created_at: 2.days.ago
    )
    Datapass::EmployeeHistory.create!(
      geid: "recent_t_geid", organization: @organization, location: @location,
      termination_code: "T", created_at: 1.day.ago
    )

    # User with history 'T' then 'A'
    Datapass::EmployeeDetail.create!(
      geid: "recent_a_geid",
      first_name: "Recent", last_name: "A", email: "recent_a@example.com",
      organization: @organization, location: @location, eid: "TERM_EID"
    )
    Datapass::EmployeeHistory.create!(
      geid: "recent_a_geid", organization: @organization, location: @location,
      termination_code: "T", created_at: 2.days.ago
    )
    Datapass::EmployeeHistory.create!(
      geid: "recent_a_geid", organization: @organization, location: @location,
      termination_code: "A", created_at: 1.day.ago
    )

    assert_difference "User.count", 1 do
      Datapass::CreateOrganizationUsersJob.perform_now(@organization.id)
    end

    assert_not User.exists?(geid: "recent_t_geid")
    assert User.exists?(geid: "recent_a_geid")
  end
end
