class Datapass::MchireNewHireJob < ApplicationJob
  queue_as :default

  def perform(data, nsn, timestamp)
    payload = data.is_a?(String) ? JSON.parse(data) : data
    return if payload.nil?

    location = Organization::Location.find_by(number: nsn.to_i.to_s)
    if location.nil?
      puts "Location not found for NSN: #{nsn}"
      return
    end

    organization = location.organization

    mchire_location = payload["location"]
    poll_date = parse_date(payload["date"])
    created_at_source = parse_time(payload["created"])
    
    ahs = payload.dig("AH0", "AHS") || {}
    ds = ahs["ds"]
    oid = ahs["oid"]

    h1 = payload.dig("H0", "H1")
    if h1
      nh_id = h1["id"]
      
      new_hire = Datapass::NewHire.find_or_initialize_by(nh_id: nh_id, organization_id: organization.id)

      ssn_obj = h1["NV"]&.find { |nv| nv["n"] == "SSN" }
      ssn = ssn_obj ? ssn_obj["v"] : nil

      ej = h1["EJ"] || {}
      ea = h1["EA"] || {}
      es = h1["ES"] || {}

      new_hire.assign_attributes(
        location_id: location.id,
        mchire_location: mchire_location,
        poll_date: poll_date,
        created_at_source: created_at_source,
        ds: ds,
        oid: oid,
        a: h1["a"],
        bdt: parse_date(h1["bdt"]),
        c: h1["c"],
        e: h1["e"],
        fn: h1["fn"],
        mn: h1["mn"],
        hs: h1["hs"],
        ln: h1["ln"],
        p: h1["p"],
        st: h1["st"],
        z: h1["z"],
        jtc: ej["jtc"],
        job_title: ej["c"],
        r: ej["r"],
        ea_a: ea["a"],
        ea_dt: ea["dt"],
        nm: es["nm"],
        ssn: ssn
      )

      unless new_hire.save
        puts "Failed to save NewHire record for ID #{nh_id}: #{new_hire.errors.full_messages.join(', ')}"
      end
    end
  end

  private

  def parse_date(date_str)
    return nil if date_str.blank?
    begin
      Date.strptime(date_str.to_s, "%Y%m%d")
    rescue Date::Error
      nil
    end
  end

  def parse_time(time_str)
    return nil if time_str.blank?
    begin
      Time.zone.parse(time_str.to_s)
    rescue ArgumentError
      nil
    end
  end
end
