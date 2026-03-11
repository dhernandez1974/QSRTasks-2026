require "test_helper"

class Datapass::CreateOrganizationUsersFilteringJobTest < ActiveJob::TestCase
  setup do
    # Update organizations to match our test EIDs
    @primary_org = organizations(:one)
    @primary_org.update!(eid: "primary_eid", secondary_eids: ["secondary_eid"])
    
    @secondary_org = organizations(:two)
    @secondary_org.update!(eid: "secondary_eid", secondary_eids: ["primary_eid"])
    
    # Clean up GEID-related tables to avoid noise
    User.delete_all
    Datapass::EmployeeDetail.delete_all
    Datapass::EmployeeHistory.delete_all
    Datapass::HrPersonal.delete_all
    Datapass::HrSsn.delete_all
    Datapass::Idmgmt.delete_all
    Datapass::Identification.delete_all
    
    @location = organization_locations(:one)
  end

  test "organization should include its own and secondary organizations' geids" do
    # GEID for primary org
    Datapass::EmployeeDetail.create!(geid: "geid_primary", eid: "primary_eid", organization: @primary_org, location: @location)
    
    # GEID for secondary org (associated via secondary_eids)
    Datapass::EmployeeDetail.create!(geid: "geid_secondary", eid: "secondary_eid", organization: @secondary_org, location: @location)
    
    # GEID for unrelated org
    @unrelated_org = organizations(:one).dup
    @unrelated_org.update!(name: "Unrelated Org", eid: "unrelated_eid")
    Datapass::EmployeeDetail.create!(geid: "geid_unrelated", eid: "unrelated_eid", organization: @unrelated_org, location: @location)

    # Job for primary org
    Datapass::CreateOrganizationUsersJob.perform_now(@primary_org.id)

    assert_not_nil User.find_by(geid: "geid_primary")
    assert_not_nil User.find_by(geid: "geid_secondary")
    assert_nil User.find_by(geid: "geid_unrelated")
  end

  test "organization should only include its own geids and geids matching its secondary_eids" do
    # GEID matching secondary org's eid
    Datapass::EmployeeDetail.create!(geid: "geid_sec_match", eid: "secondary_eid", organization: @secondary_org, location: @location)
    
    # GEID matching secondary org's secondary_eids
    Datapass::EmployeeDetail.create!(geid: "geid_pri_match", eid: "primary_eid", organization: @primary_org, location: @location)
    
    # GEID for unrelated org
    @unrelated_org = organizations(:one).dup
    @unrelated_org.update!(name: "Other Org", eid: "unrelated_eid")
    Datapass::EmployeeDetail.create!(geid: "geid_other", eid: "unrelated_eid", organization: @unrelated_org, location: @location)

    # Job for secondary org
    Datapass::CreateOrganizationUsersJob.perform_now(@secondary_org.id)

    assert_not_nil User.find_by(geid: "geid_sec_match")
    assert_not_nil User.find_by(geid: "geid_pri_match")
    assert_nil User.find_by(geid: "geid_other")
  end
end
