require "test_helper"

class Datapass::LifelenzIdmgmtJobTest < ActiveJob::TestCase
  setup do
    @organization = organizations(:one)
    @location = locations(:one)
    @location.update!(number: "1480") # Set matching NSN from sample file
    
    # If the file in tmp is missing, skip the tests
    sample_file = Rails.root.join('tmp/0001480-LIFELENZ-LZ-HR-IdMgmtFull.json')
    if File.exist?(sample_file)
      raw_data = File.read(sample_file)
      @json_data = eval(raw_data).to_json
    else
      @json_data = nil
    end
  end

  test "should create idmgmt records from json" do
    skip "Sample data file missing" if @json_data.nil?
    # Correcting the JSON if it's actually a Ruby hash string in the file
    # Based on the cat output: {"country" => "us", ...}
    # If the job uses JSON.parse, it MUST be valid JSON.
    
    # Let's assume the file in tmp is valid JSON for the test, or parse it as Ruby if that's what it is.
    # But usually these files are JSON.
    
    # If I use eval(@json_data), it might work if it's a Ruby hash.
    # But let's try to fix it to JSON if needed.
    
    # Actually, let's just use the job's perform method.
    
    assert_difference("Datapass::Idmgmt.count", 41) do # Sample file has 41 people
      Datapass::LifelenzIdmgmtJob.perform_now(@json_data, "01480", "20251008120000")
    end

    idmgmt = Datapass::Idmgmt.find_by(geid: "516141")
    assert_not_nil idmgmt
    assert_equal "Estela", idmgmt.first_name
    assert_equal "Martinez", idmgmt.last_name
    assert_equal @location.id, idmgmt.location_id
    assert_equal @organization.id, idmgmt.organization_id
    assert_equal Date.new(2001, 10, 19), idmgmt.organization_start_date
    assert_equal "us", idmgmt.country
    assert_equal "1000891057", idmgmt.gerid
    assert_equal "195500309798", idmgmt.glin
  end

  test "should update existing idmgmt record" do
    skip "Sample data file missing" if @json_data.nil?
    # Create existing record
    existing = Datapass::Idmgmt.create!(
      geid: "516141",
      organization: @organization,
      location: @location,
      first_name: "OldName",
      nsn: "01480" # Added to match what job might use or for completeness
    )
    
    # Check that it exists before job
    assert_equal "OldName", Datapass::Idmgmt.find_by(geid: "516141").first_name

    # The job finds by geid AND organization_id
    # Ensure @organization is used
    Datapass::LifelenzIdmgmtJob.perform_now(@json_data, "01480", "20251008120000")
    
    existing.reload
    assert_equal "Estela", existing.first_name
  end
end
