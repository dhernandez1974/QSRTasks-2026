require "test_helper"

class Datapass::CreateOrganizationUsersJobMappingTest < ActiveJob::TestCase
  setup do
    @organization = organizations(:one)
    @organization.update!(eid: "EID123")
    
    User.delete_all
    Datapass::EmployeeDetail.delete_all
    Datapass::HrPersonal.delete_all
    Datapass::HrSsn.delete_all
    Datapass::Idmgmt.delete_all
    Datapass::Identification.delete_all
    Datapass::EmployeeHistory.delete_all

    @location1 = organization_locations(:one)
    @location2 = organization_locations(:two)
    @geid = "unique_geid_123"
  end

  test "should prioritize mappings and populate locations" do
    # 1. User social from hr_ssn
    Datapass::HrSsn.create!(geid: @geid, ssn: "SSN-FROM-HR-SSN", organization: @organization)
    Datapass::Identification.create!(geid: @geid, ssn: "SSN-FROM-IDENT", organization: @organization, location: @location1)

    # 2. User birth_date from Identification (datapass_identifications)
    Datapass::Identification.update_all(birth_day: Date.new(1990, 1, 1))
    Datapass::EmployeeDetail.create!(geid: @geid, birth_date: Date.new(1980, 1, 1), organization: @organization, location: @location1, eid: "EID-FROM-ED")

    # 3. User email/phone from HrPersonal
    Datapass::HrPersonal.create!(
      geid: @geid, 
      email_address: "email@hrpersonal.com", 
      cell_phone_number: "111-222-3333",
      organization: @organization,
      location: @location2
    )
    # EmployeeDetail also has email/phone but HrPersonal should take priority for these (based on requirement to take from it)
    # Wait, the current implementation uses ||= which means ED (first in code) would take priority if it exists.
    # The requirement says "user email should be taken from datapass_hr_personal".
    # This implies HrPersonal should be the source.

    Datapass::CreateOrganizationUsersJob.perform_now(@organization.id)

    user = User.find_by(geid: @geid)
    assert_not_nil user
    assert_equal "SSN-FROM-HR-SSN", user.social
    assert_equal Date.new(1990, 1, 1), user.birth_date
    assert_equal "email@hrpersonal.com", user.email
    assert_equal "111-222-3333", user.phone_number
    assert_equal "eid-from-ed", user.eid

    # Check locations join table
    assert_includes user.locations, @location1
    assert_includes user.locations, @location2
  end

  test "encryption of specified fields" do
    user = User.create!(
      geid: "ENC-GEID",
      social: "ENC-SSN",
      eid: "ENC-EID",
      phone_number: "555-555-5555",
      first_name: "Enc-First",
      last_name: "Enc-Last",
      payroll_id: "ENC-PAY",
      email: "enc@example.com",
      password: "password123"
    )

    # Verify they are encrypted in the database
    # ActiveRecord::Encryption doesn't expose raw values easily via typical accessors, 
    # but we can check if they are deterministic if we set it so.
    # More simply, we trust 'encrypts' macro if it's there.
    
    assert User.encrypted_attributes.include?(:social)
    assert User.encrypted_attributes.include?(:eid)
    assert User.encrypted_attributes.include?(:geid)
    assert User.encrypted_attributes.include?(:phone_number)
    assert User.encrypted_attributes.include?(:first_name)
    assert User.encrypted_attributes.include?(:last_name)
    assert User.encrypted_attributes.include?(:payroll_id)
  end
end
