require "test_helper"

class Datapass::MchireNewHireJobTest < ActiveJob::TestCase
  setup do
    @organization = organizations(:one)
    @location = locations(:one)
    @location.update!(number: "1480")

    @sample_file = Rails.root.join('tmp/0001480-Paradox-McHire-HIRE-New.json')
    if File.exist?(@sample_file)
      @json_data = File.read(@sample_file)
    end
  end

  test "should create new_hire record from json" do
    skip "Sample data file missing at #{@sample_file}" unless @json_data
    
    assert_difference("Datapass::NewHire.count", 1) do
      Datapass::MchireNewHireJob.perform_now(@json_data, "01480", "20260224180443")
    end

    new_hire = Datapass::NewHire.find_by(nh_id: "72036931454419")
    assert_not_nil new_hire
    assert_equal "Camery", new_hire.fn
    assert_equal "Corbbrey", new_hire.ln
    assert_equal "726-253-3289", new_hire.p
    assert_equal "cameryworthey210@gmail.com", new_hire.e
    assert_equal "640221448", new_hire.ssn
    assert_equal "General Manager", new_hire.job_title
    assert_equal "13.00", new_hire.r
    assert_equal Date.new(1991, 4, 20), new_hire.bdt
    assert_equal Date.new(2026, 2, 24), new_hire.poll_date
    assert_equal "01480", new_hire.mchire_location
    assert_equal @location.id, new_hire.location_id
    assert_equal @organization.id, new_hire.organization_id
  end

  test "should update existing new_hire record" do
    skip "Sample data file missing at #{@sample_file}" unless @json_data
    
    existing = Datapass::NewHire.create!(
      nh_id: "72036931454419",
      organization: @organization,
      location: @location,
      fn: "OldName"
    )

    Datapass::MchireNewHireJob.perform_now(@json_data, "01480", "20260224180443")

    existing.reload
    assert_equal "Camery", existing.fn
  end
end
