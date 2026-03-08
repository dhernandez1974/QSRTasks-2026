require "test_helper"

class Datapass::LifelenzIdentificationJobTest < ActiveJob::TestCase
  setup do
    @organization = organizations(:one)
    @location = organization_locations(:one)
    @location.update!(number: "1480") # Ensure the number matches the sample filename
    @nsn = "0001480"
    @timestamp = "20260307120000"
    @sample_file = Rails.root.join("tmp", "0001480-LIFELENZ-LZ-HR-Identification.json")
  end

  test "should create identification records from sample file" do
    unless File.exist?(@sample_file)
      skip "Sample data file missing at #{@sample_file}"
    end

    data = File.read(@sample_file)

    assert_difference("Datapass::Identification.count", 43) do
      Datapass::LifelenzIdentificationJob.perform_now(data, @nsn, @timestamp)
    end

    # Check a specific record from the sample
    identification = Datapass::Identification.find_by(geid: "516141")
    assert_not_nil identification
    assert_equal "Estela", identification.first_name
    assert_equal "Martinez", identification.last_initial
    assert_equal Date.new(1953, 7, 14), identification.birth_day
    assert_equal "9531", identification.ssn
    assert_equal "HISPANIC", identification.ethnicity
    assert_equal "FEMALE", identification.gender
    assert_equal @location.id, identification.location_id
    assert_equal @organization.id, identification.organization_id
    assert_not_nil identification.emp_job_title_history
  end

  test "should update existing identification records" do
    unless File.exist?(@sample_file)
      skip "Sample data file missing at #{@sample_file}"
    end

    data = File.read(@sample_file)

    # Pre-create a record to verify update
    existing = Datapass::Identification.create!(
      geid: "516141",
      organization: @organization,
      location: @location,
      first_name: "Old Name",
      last_initial: "Old Initial"
    )

    assert_difference("Datapass::Identification.count", 42) do
      # This should update 1 and create 42 new ones (since there are 43 in the file)
      Datapass::LifelenzIdentificationJob.perform_now(data, @nsn, @timestamp)
    end

    existing.reload
    assert_equal "Estela", existing.first_name
    assert_equal "Martinez", existing.last_initial
  end
end
