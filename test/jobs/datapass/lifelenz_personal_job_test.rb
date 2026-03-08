require "test_helper"

class Datapass::LifelenzPersonalJobTest < ActiveJob::TestCase
  setup do
    @organization = organizations(:one)
    @location = locations(:one)
    @location.update!(number: "1480")

    @sample_file = Rails.root.join('tmp/0001480-LIFELENZ-LZ-HR-Personal.json')
    if File.exist?(@sample_file)
      @raw_data = File.read(@sample_file)
    end
  end

  test "should create hr_personal records from sample data" do
    skip "Sample data file missing at #{@sample_file}" unless @raw_data

    # Let's count GEIDs in the sample file to know how many to expect
    expected_count = @raw_data.scan(/\"GEID\"\s*=>\s*\"(\d+)\"/).size

    assert_difference("Datapass::HrPersonal.count", expected_count) do
      Datapass::LifelenzPersonalJob.perform_now(@raw_data, "1480", "20260307120000")
    end

    # Verify one record (the first one from my head earlier)
    person = Datapass::HrPersonal.find_by(geid: "516141")
    assert_not_nil person
    assert_equal "Estela", person.first_name
    assert_equal "Martinez", person.last_name
    assert_equal "210-222-8388", person.cell_phone_number
    assert_equal "019867b5-a1dc-7694-8383-1e0270962307@noop.lifelenz.net", person.email_address
    assert_equal Date.new(1953, 7, 14), person.date_of_birth
    assert_equal @location.id, person.location_id
    assert_equal @organization.id, person.organization_id
  end

  test "should update existing hr_personal record" do
    skip "Sample data file missing at #{@sample_file}" unless @raw_data

    existing = Datapass::HrPersonal.create!(
      geid: "516141",
      organization: @organization,
      location: @location,
      first_name: "OldName",
      last_name: "OldLastName"
    )

    Datapass::LifelenzPersonalJob.perform_now(@raw_data, "1480", "20260307120000")

    existing.reload
    assert_equal "Estela", existing.first_name
    assert_equal "Martinez", existing.last_name
  end
end
