require "test_helper"

class Datapass::EmployeeHistoryJobTest < ActiveJob::TestCase
  setup do
    @organization = organizations(:one)
    # Ensure the organization has an EID that matches our test data or location number
    @location = organization_locations(:one)
    @location.update!(number: "1480")
    
    @test_file_path = Rails.root.join("tmp", "test_employee_history.json")
    @test_data = [
      {
        "GEID" => "516141",
        "OrganizationStartDate" => "20011019",
        "TerminationDate" => nil,
        "OrientationDate" => "20011019",
        "CompanyServiceDate" => nil,
        "ReviewDueDate" => "20171031",
        "FollowUpOrientationDate" => "20011118",
        "TerminationEntryDate" => nil,
        "TerminationReason" => "ACTIVE",
        "TerminationCode" => "A",
        "StoreHistory" => [
          {
            "StartDate" => "20011019",
            "PrimaryTimeCard" => nil,
            "HomeOrShared" => "Home",
            "Store" => "01480",
            "SecondaryTimeCard" => nil,
            "EndDate" => nil
          }
        ],
        "RepeatingFullJTCHistory" => [
          {
            "PayRate" => 5.5,
            "StartDate" => "20011019",
            "Type" => "P",
            "JTC" => "00650",
            "EndDate" => "20020501"
          }
        ]
      }
    ]
    File.write(@test_file_path, @test_data.to_json)
  end

  teardown do
    File.delete(@test_file_path) if @test_file_path && File.exist?(@test_file_path)
  end

  test "should create employee history records from payload" do
    assert_difference("Datapass::EmployeeHistory.count", 1) do
      Datapass::EmployeeHistoryJob.perform_now(@test_data, "1480", "20260309123456000")
    end

    history = Datapass::EmployeeHistory.find_by(geid: "516141")
    assert_not_nil history
    assert_equal @organization.id, history.organization_id
    assert_equal @location.id, history.location_id
    assert_equal Date.parse("2001-10-19"), history.organization_start_date
    assert_equal "ACTIVE", history.termination_reason
    assert_equal "A", history.termination_code
    assert_equal 1, history.store_history.length
    assert_equal "01480", history.store_history.first["Store"]
    assert_equal 1, history.repeating_full_jtc_history.length
  end

  test "should update existing employee history records" do
    # Create initial record
    Datapass::EmployeeHistory.create!(
      geid: "516141",
      organization: @organization,
      location: @location,
      termination_reason: "OLD REASON"
    )

    assert_no_difference("Datapass::EmployeeHistory.count") do
      Datapass::EmployeeHistoryJob.perform_now(@test_data, "1480", "20260309123456000")
    end

    history = Datapass::EmployeeHistory.find_by(geid: "516141")
    assert_equal "ACTIVE", history.termination_reason
  end

  test "should handle JSON string payload" do
    json_payload = @test_data.to_json

    assert_difference("Datapass::EmployeeHistory.count", 1) do
      Datapass::EmployeeHistoryJob.perform_now(json_payload, "1480", "20260309123456000")
    end
    
    assert_not_nil Datapass::EmployeeHistory.find_by(geid: "516141")
  end
end
