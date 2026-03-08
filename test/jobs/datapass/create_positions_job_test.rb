require "test_helper"

class Datapass::CreatePositionsJobTest < ActiveJob::TestCase
  setup do
    @organization = organizations(:one)
    @location = organization_locations(:one)
    # Create some employee details with specific job titles
    Datapass::EmployeeDetail.create!(
      geid: "geid1",
      organization: @organization,
      location: @location,
      jtc: "101",
      primary_job_title: "CREW"
    )
    Datapass::EmployeeDetail.create!(
      geid: "geid2",
      organization: @organization,
      location: @location,
      jtc: "102",
      primary_job_title: "MANAGER"
    )
    # Different JTC for same job title should create another record
    Datapass::EmployeeDetail.create!(
      geid: "geid3",
      organization: @organization,
      location: @location,
      jtc: "103",
      primary_job_title: "CREW"
    )
    # Same JTC and job title should be idempotent
    Datapass::EmployeeDetail.create!(
      geid: "geid4",
      organization: @organization,
      location: @location,
      jtc: "101",
      primary_job_title: "CREW"
    )
  end

  test "should create unique jtc positions from employee details" do
    assert_difference("Datapass::JtcPosition.count", 3) do
      Datapass::CreatePositionsJob.perform_now(organization_id: @organization.id)
    end

    assert Datapass::JtcPosition.exists?(jtc: "101", job_title: "CREW")
    assert Datapass::JtcPosition.exists?(jtc: "102", job_title: "MANAGER")
    assert Datapass::JtcPosition.exists?(jtc: "103", job_title: "CREW")
  end

  test "is idempotent" do
    Datapass::CreatePositionsJob.perform_now(organization_id: @organization.id)
    initial_count = Datapass::JtcPosition.count

    assert_no_difference("Datapass::JtcPosition.count") do
      Datapass::CreatePositionsJob.perform_now(organization_id: @organization.id)
    end
    assert_equal initial_count, Datapass::JtcPosition.count
  end
end