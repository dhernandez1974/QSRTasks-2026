require "test_helper"

class Datapass::CreateOrganizationUsersJobTest < ActiveJob::TestCase
  setup do
    @organization = organizations(:one)
    @organization.update!(eid: "EID123")
    
    # Clean up to ensure a predictable state
    User.where.not(id: users(:one).id).delete_all
    Datapass::EmployeeDetail.delete_all
    Datapass::HrPersonal.delete_all
    Datapass::HrSsn.delete_all
    Datapass::Idmgmt.delete_all
    Datapass::Identification.delete_all
    Datapass::EmployeeHistory.delete_all

    @location = organization_locations(:one)
    @geid = "unique_geid_123"
  end

  test "should create a new user from aggregated data" do
    Datapass::EmployeeDetail.create!(
      geid: @geid,
      first_name: "John",
      last_name: "Doe",
      email: "john.doe@example.com",
      organization: @organization,
      location: @location,
      eid: "EID123",
      payroll_id: "PAY123"
    )

    Datapass::Identification.create!(
      geid: @geid,
      ssn: "123-45-6789",
      organization: @organization,
      location: @location
    )

    # Calculate initial number of users the job will create from fixtures that match EID123
    # Only records matching @organization.eid ("EID123") will be processed.
    
    # Let's see how many records match EID123.
    # Our new @geid record matches.
    
    assert_difference "User.count", 1 do
      Datapass::CreateOrganizationUsersJob.perform_now(@organization.id)
    end

    user = User.find_by(geid: @geid)
    assert_not_nil user
    assert_equal "John", user.first_name
    assert_equal "Doe", user.last_name
    assert_equal "john.doe@example.com", user.email
    assert_equal "eid123", user.eid
    assert_equal "PAY123", user.payroll_id
    assert_equal "123-45-6789", user.social
    assert_equal @organization.id, user.organization_id
    assert_equal @location.id, user.location_id
  end

  test "should update existing user with new data" do
    # Create user first so it's not counted as 'new' by the job
    user = User.create!(
      geid: @geid,
      email: "old@example.com",
      first_name: "Oldname",
      password: "password123",
      organization: @organization
    )

    Datapass::HrPersonal.create!(
      geid: @geid,
      first_name: "NewName",
      last_name: "LastName",
      cell_phone_number: "1234567890",
      organization: @organization,
      location: @location
    )

    # How many users would be created from fixtures that match EID123?
    # @geid is already created in User table in setup of this test, so it's not 'new'.
    
    assert_difference "User.count", 0 do
      Datapass::CreateOrganizationUsersJob.perform_now(@organization.id)
    end

    user.reload
    assert_equal "Oldname", user.first_name # Should not overwrite if already present
    assert_equal "Lastname", user.last_name
    assert_equal "123-456-7890", user.phone_number
  end

  test "should assign position to user based on JTC" do
    jtc_code = "JTC123"
    position_name = "Store Manager"
    
    # Create Organization Position
    dept = Organization::Department.create!(name: "Ops", organization: @organization, updated_by: users(:one))
    org_pos = Organization::Position.create!(
      name: position_name,
      organization: @organization,
      department: dept,
      updated_by: users(:one),
      rate_type: "Salary",
      authorized: Organization::Position::AUTHORIZED,
      authorization_level: "Location",
      job_tier: "Restaurant",
      job_class: "Management"
    )

    # Create JTC Position mapping
    Datapass::JtcPosition.create!(
      jtc: jtc_code,
      job_title: "Store Manager Title",
      matching_position: position_name
    )

    # Create Employee Detail with JTC
    Datapass::EmployeeDetail.create!(
      geid: @geid,
      first_name: "John",
      last_name: "Doe",
      email: "john.doe@example.com",
      organization: @organization,
      location: @location,
      eid: "EID123",
      jtc: jtc_code
    )

    assert_difference "User.count", 1 do
      Datapass::CreateOrganizationUsersJob.perform_now(@organization.id)
    end

    user = User.find_by(geid: @geid)
    assert_not_nil user
    assert_equal org_pos.id, user.position_id
  end
end
