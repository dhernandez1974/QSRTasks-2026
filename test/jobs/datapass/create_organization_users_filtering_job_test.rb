require "test_helper"

class Datapass::CreateOrganizationUsersFilteringJobTest < ActiveJob::TestCase
  setup do
    @primary_org = organizations(:one)
    @primary_org.update!(eid: "primary_eid", primary_operator: true)
    
    @secondary_org = organizations(:two)
    @secondary_org.update!(eid: "secondary_eid", primary_eid: "primary_eid", primary_operator: false)
    
    @unrelated_org = Organization.create!(
      name: "Unrelated Org",
      phone: "999-999-9999",
      eid: "unrelated_eid",
      street: "123 Main St",
      city: "Anytown",
      state: "CA",
      zip: "12345",
      primary_operator: false
    )
    
    # Create a contact for @unrelated_org because Organization requires it in some contexts or validations (though not explicitly in model)
    User.create!(email: "contact@unrelated.com", password: "password", organization: @unrelated_org)

    @location = organization_locations(:one)
  end

  test "primary operator should include its own and associated organizations' geids" do
    # GEID for primary org
    Datapass::EmployeeDetail.create!(geid: "geid_primary", eid: "primary_eid", organization: @primary_org, location: @location)
    
    # GEID for secondary org (associated with primary via primary_eid)
    Datapass::EmployeeDetail.create!(geid: "geid_secondary", eid: "secondary_eid", organization: @secondary_org, location: @location)
    
    # GEID for unrelated org
    Datapass::EmployeeDetail.create!(geid: "geid_unrelated", eid: "unrelated_eid", organization: @unrelated_org, location: @location)

    # Job for primary org
    Datapass::CreateOrganizationUsersJob.perform_now(@primary_org.id)

    assert_not_nil User.find_by(geid: "geid_primary")
    assert_not_nil User.find_by(geid: "geid_secondary")
    assert_nil User.find_by(geid: "geid_unrelated")
  end

  test "secondary org should only include its own geids and geids matching its primary_eid" do
    # GEID matching secondary org's eid
    Datapass::EmployeeDetail.create!(geid: "geid_sec_match", eid: "secondary_eid", organization: @secondary_org, location: @location)
    
    # GEID matching secondary org's primary_eid
    Datapass::EmployeeDetail.create!(geid: "geid_pri_match", eid: "primary_eid", organization: @primary_org, location: @location)
    
    # GEID for unrelated org
    Datapass::EmployeeDetail.create!(geid: "geid_other", eid: "unrelated_eid", organization: @unrelated_org, location: @location)

    # Job for secondary org
    Datapass::CreateOrganizationUsersJob.perform_now(@secondary_org.id)

    assert_not_nil User.find_by(geid: "geid_sec_match")
    assert_not_nil User.find_by(geid: "geid_pri_match")
    assert_nil User.find_by(geid: "geid_other")
  end
end
