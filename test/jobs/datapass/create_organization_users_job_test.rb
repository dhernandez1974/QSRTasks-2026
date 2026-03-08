require "test_helper"

class Datapass::CreateOrganizationUsersJobTest < ActiveJob::TestCase
  setup do
    @organization = organizations(:one)
    @organization.update!(eid: "EID123")
    
    # Update fixtures to NOT match our test EID to avoid interference
    Datapass::EmployeeDetail.where(organization_id: @organization.id).update_all(eid: "OTHER")
    Datapass::HrPersonal.where(organization_id: @organization.id).delete_all
    Datapass::HrSsn.where(organization_id: @organization.id).delete_all
    Datapass::Idmgmt.where(organization_id: @organization.id).delete_all
    Datapass::Identification.where(organization_id: @organization.id).delete_all

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

  test "should handle multiple GEIDs" do
    Datapass::HrSsn.create!(geid: "USER1", ssn: "SSN1", organization: @organization)
    Datapass::HrSsn.create!(geid: "USER2", ssn: "SSN2", organization: @organization)

    # We need to update fixtures' organizations to have the same EID if we want them to be included
    # or just count our own new ones.
    # Given the filtering, only records matching @organization.eid ("EID123") will be processed.
    # Our new records should match.
    
    # Let's see how many records match EID123.
    # EmployeeDetail matches via 'eid' column. Others via organization's eid.
    
    expected_new_users = 3 # @geid (from previous tests if not cleared, but here it's fresh), USER1, USER2
    # Wait, @geid is NOT created in this test. So only USER1 and USER2.
    # But wait, there might be others.
    
    # Let's just focus on the ones we create here.
    assert_difference "User.count", 2 do
      Datapass::CreateOrganizationUsersJob.perform_now(@organization.id)
    end
  end
end
