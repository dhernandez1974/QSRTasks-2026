class Datapass::CreateOrganizationUsersJob < ApplicationJob
  queue_as :default

  def perform(organization_id)
    organization = Organization.find(organization_id)
    eids = [ organization.eid ]
    eids << organization.primary_eid if organization.primary_eid.present? && !organization.primary_operator?

    if organization.primary_operator?
      eids += Organization.where(primary_eid: organization.eid).where(primary_operator: false).pluck(:eid)
    end

    eids = eids.uniq.compact_blank

    geids = collect_geids_by_eids(eids)
    
    geids.each do |geid|
      next if terminated?(geid)
      user_data = aggregate_user_data(geid)
      create_or_update_user(geid, user_data)
    end
  end

  private

  def terminated?(geid)
    history = Datapass::EmployeeHistory.where(geid: geid).order(created_at: :desc).first
    return false unless history
    
    # A user should be created if the value is nil, null, or "A"
    # Otherwise they are considered terminated (or not active)
    ![nil, "", "A"].include?(history.termination_code)
  end

  def collect_geids_by_eids(eids)
    (
      Datapass::EmployeeHistory.where(organization_id: Organization.where(eid: eids)).pluck(:geid) +
      Datapass::EmployeeDetail.where(eid: eids).pluck(:geid) +
      Datapass::HrPersonal.where(organization_id: Organization.where(eid: eids).select(:id)).pluck(:geid) +
      Datapass::HrSsn.where(organization_id: Organization.where(eid: eids).select(:id)).pluck(:geid) +
      Datapass::Idmgmt.where(organization_id: Organization.where(eid: eids).select(:id)).pluck(:geid) +
      Datapass::Identification.where(organization_id: Organization.where(eid: eids).select(:id)).pluck(:geid)
    ).map { |g| g.to_s.downcase }.uniq.compact_blank
  end

  def aggregate_user_data(geid)
    data = { location_ids: [] }

    # HrPersonal
    hp = Datapass::HrPersonal.find_by(geid: geid)
    if hp
      data[:first_name] ||= hp.first_name
      data[:last_name] ||= hp.last_name
      data[:email] = hp.email_address if hp.email_address.present?
      data[:phone_number] = hp.cell_phone_number if hp.cell_phone_number.present?
      data[:payroll_id] ||= hp.payroll_id
      data[:birth_date] ||= hp.date_of_birth
      data[:organization_id] ||= hp.organization_id
      data[:location_ids] << hp.location_id if hp.location_id.present?
    end

    # EmployeeDetail
    ed = Datapass::EmployeeDetail.find_by(geid: geid)
    if ed
      data[:first_name] ||= ed.first_name
      data[:last_name] ||= ed.last_name
      data[:email] ||= ed.email
      data[:phone_number] ||= ed.primary_phone
      data[:eid] = ed.eid if ed.eid.present?
      data[:payroll_id] ||= ed.payroll_id
      data[:birth_date] ||= ed.birth_date
      data[:hire_date] ||= ed.organization_start_date
      data[:organization_id] ||= ed.organization_id
      data[:location_ids] << ed.location_id if ed.location_id.present?

      if ed.jtc.present?
        jtc_pos = Datapass::JtcPosition.find_by(jtc: ed.jtc)
        if jtc_pos&.matching_position.present?
          org_pos = Organization::Position.find_by(organization_id: data[:organization_id], name: jtc_pos.matching_position)
          data[:position_id] ||= org_pos.id if org_pos
        end
      end
    end

    # Idmgmt
    idm = Datapass::Idmgmt.find_by(geid: geid)
    if idm
      data[:first_name] ||= idm.first_name
      data[:last_name] ||= idm.last_name
      data[:email] ||= idm.email
      data[:payroll_id] ||= idm.payroll_id
      data[:hire_date] ||= idm.organization_start_date
      data[:organization_id] ||= idm.organization_id
      data[:location_ids] << idm.location_id if idm.location_id.present?
    end

    # Identification
    ident = Datapass::Identification.find_by(geid: geid)
    if ident
      data[:first_name] ||= ident.first_name
      data[:last_name] ||= ident.last_name
      data[:email] ||= ident.email_address
      data[:social] ||= ident.ssn
      data[:birth_date] = ident.birth_day if ident.birth_day.present?
      data[:organization_id] ||= ident.organization_id
      data[:location_ids] << ident.location_id if ident.location_id.present?
    end

    # HrSsn
    hssn = Datapass::HrSsn.find_by(geid: geid)
    if hssn
      data[:social] = hssn.ssn if hssn.ssn.present?
      data[:organization_id] ||= hssn.organization_id
    end

    data[:location_ids] = data[:location_ids].uniq.compact
    data
  end

  def create_or_update_user(geid, data)
    user = User.find_by(geid: geid) || User.new(geid: geid)
    
    # Generate a random password for new users since devise requires it
    if user.new_record?
      user.password = SecureRandom.hex(10)
    end

    # Set attributes if they are present and user's current attribute is blank
    data.each do |key, value|
      next if key == :location_ids
      user.send("#{key}=", value) if value.present? && user.send(key).blank?
    end

    # Explicitly update position if it's already set in data but blank on user
    # (The loop above handles this, but being explicit doesn't hurt if we want to ensure it's updated)
    # Actually the loop is fine. Let's just make sure position_id is included in the loop.

    # Explicitly update locations
    if data[:location_ids].present?
      user.locations = Organization::Location.where(id: data[:location_ids])
      user.location_id = data[:location_ids].first if user.location_id.blank?
    end

    # Default email if not found in any record
    if user.email.blank?
      user.email = "#{geid}@example.com"
    end

    unless user.save
      Rails.logger.error "Failed to save user with GEID #{geid}: #{user.errors.full_messages.join(', ')}"
    end
  end
end
