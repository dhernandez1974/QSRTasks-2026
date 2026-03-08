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
      user_data = aggregate_user_data(geid)
      create_or_update_user(geid, user_data)
    end
  end

  private

  def collect_geids_by_eids(eids)
    (
      Datapass::EmployeeDetail.where(eid: eids).pluck(:geid) +
      Datapass::HrPersonal.where(organization_id: Organization.where(eid: eids).select(:id)).pluck(:geid) +
      Datapass::HrSsn.where(organization_id: Organization.where(eid: eids).select(:id)).pluck(:geid) +
      Datapass::Idmgmt.where(organization_id: Organization.where(eid: eids).select(:id)).pluck(:geid) +
      Datapass::Identification.where(organization_id: Organization.where(eid: eids).select(:id)).pluck(:geid)
    ).map { |g| g.to_s.downcase }.uniq.compact_blank
  end

  def aggregate_user_data(geid)
    data = {}

    # EmployeeDetail
    ed = Datapass::EmployeeDetail.find_by(geid: geid)
    if ed
      data[:first_name] ||= ed.first_name
      data[:last_name] ||= ed.last_name
      data[:email] ||= ed.email
      data[:phone_number] ||= ed.primary_phone
      data[:eid] ||= ed.eid
      data[:payroll_id] ||= ed.payroll_id
      data[:birth_date] ||= ed.birth_date
      data[:hire_date] ||= ed.organization_start_date
      data[:organization_id] ||= ed.organization_id
      data[:location_id] ||= ed.location_id
    end

    # HrPersonal
    hp = Datapass::HrPersonal.find_by(geid: geid)
    if hp
      data[:first_name] ||= hp.first_name
      data[:last_name] ||= hp.last_name
      data[:email] ||= hp.email_address
      data[:phone_number] ||= hp.cell_phone_number
      data[:payroll_id] ||= hp.payroll_id
      data[:birth_date] ||= hp.date_of_birth
      data[:organization_id] ||= hp.organization_id
      data[:location_id] ||= hp.location_id
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
      data[:location_id] ||= idm.location_id
    end

    # Identification
    ident = Datapass::Identification.find_by(geid: geid)
    if ident
      data[:first_name] ||= ident.first_name
      data[:last_name] ||= ident.last_name
      data[:email] ||= ident.email_address
      data[:social] ||= ident.ssn
      data[:birth_date] ||= ident.birth_day
      data[:organization_id] ||= ident.organization_id
      data[:location_id] ||= ident.location_id
    end

    # HrSsn
    hssn = Datapass::HrSsn.find_by(geid: geid)
    if hssn
      data[:social] ||= hssn.ssn
      data[:organization_id] ||= hssn.organization_id
    end

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
      user.send("#{key}=", value) if value.present? && user.send(key).blank?
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
