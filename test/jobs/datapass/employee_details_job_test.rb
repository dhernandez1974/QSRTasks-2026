require "test_helper"

class Datapass::EmployeeDetailsJobTest < ActiveJob::TestCase
  setup do
    @organization = organizations(:one)
    @location = locations(:one)
    @location.update!(number: "1480") # Set matching NSN from sample file

    # Sample data file contains a Ruby Hash string representation in an array
    raw_data = File.read(Rails.root.join('tmp/0001480-Accenture-HR-EmployeeDetails.json'))
    # Convert from Ruby Hash string format to valid JSON
    # The file looks like: [{"Primary Store NSN" => "01480", ...}]
    @json_data = eval(raw_data).to_json
  end

  test "should create employee_detail records from json" do
    # Sample file has 41 employees
    assert_difference("Datapass::EmployeeDetail.count", 41) do
      Datapass::EmployeeDetailsJob.perform_now(@json_data, "01480", "20260307120000")
    end

    employee = Datapass::EmployeeDetail.find_by(geid: "363968")
    assert_not_nil employee
    assert_equal "Michael", employee.first_name
    assert_equal "Thrasher", employee.last_name
    assert_equal "eo820180", employee.eid
    assert_equal "210-730-6689", employee.primary_phone
    assert_equal "STORE MANAGER", employee.primary_job_title
    assert_equal "Active", employee.employee_status
    assert_equal Date.new(2023, 12, 28), employee.organization_start_date
    assert_equal "1118", employee.birth_date
    assert_equal @location.id, employee.location_id
    assert_equal @organization.id, employee.organization_id
    
    # Check shared stores
    assert_equal "39510", employee.shared_stores.first["SharedNSN"]
  end

  test "should update existing employee_detail record" do
    # Create existing record
    existing = Datapass::EmployeeDetail.create!(
      geid: "363968",
      organization: @organization,
      location: @location,
      first_name: "OldName",
      eid: "old_eid"
    )

    Datapass::EmployeeDetailsJob.perform_now(@json_data, "01480", "20260307120000")

    existing.reload
    assert_equal "Michael", existing.first_name
    assert_equal "eo820180", existing.eid
  end
end
