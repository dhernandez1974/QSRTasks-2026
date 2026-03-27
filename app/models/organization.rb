class Organization < ApplicationRecord
  has_one :contact, -> { where(admin: true) }, class_name: "User", dependent: :destroy
  accepts_nested_attributes_for :contact
  has_many :users, dependent: :destroy
  has_many :hr_ssns, class_name: "Datapass::HrSsn", dependent: :destroy
  has_many :employee_histories, class_name: "Datapass::EmployeeHistory", dependent: :destroy
  has_many :locations, class_name: "Organization::Location", dependent: :destroy
  has_many :departments, class_name: "Organization::Department", dependent: :destroy
  has_many :positions, class_name: "Organization::Position", dependent: :destroy

  encrypts :eid, deterministic: true

  validates :name, :phone, :eid, :street, :city, :state, :zip, presence: true

  before_save :normalize_attributes
  after_create :set_default_departments
  # after_create :set_default_vendor

  def full_address
    self.street + ", " + self.city + ", " + self.state + " " + self.zip
  end

  def set_default_departments
    user = self.contact || User.find_by(organization_id: self.id)
    return unless user

    ops = Organization::Department.create!(name: "Operations", organization: self, updated_by: user)
    admin = Organization::Department.create!(name: "Administration", organization: self, updated_by: user)
    maint = Organization::Department.create!(name: "Maintenance", organization: self, updated_by: user)

    owner = Organization::Position.create!(department: admin, organization: self, name: "Owner", rate_type: "Salary",
      authorized: Organization::Position::AUTHORIZED, authorization_level: "Organization", job_tier: "Staff", job_class: "Staff",
      maintenance_team: true, maintenance_lead: false,
      updated_by: user)
    bus_director = Organization::Position.create!(department: admin, organization: self, name: "Business Director",
      rate_type: "Salary", authorized: Organization::Position::AUTHORIZED, authorization_level: "Organization", job_tier: "Staff", job_class: "Staff",
      maintenance_team: true, maintenance_lead: false,
      updated_by: user, reports_to: owner)
    hr_manager = Organization::Position.create!(department: admin, organization: self, name: "HR Manager", rate_type:
      "Salary", authorized: Organization::Position::AUTHORIZED, authorization_level: "Organization", job_tier: "Staff", job_class: "Staff",
      maintenance_team: false, maintenance_lead: false,
      updated_by: user, reports_to: bus_director)
    payroll_manager = Organization::Position.create!(department: admin, organization: self, name: "Payroll Manager",
      rate_type: "Salary", authorized: Organization::Position::AUTHORIZED, authorization_level: "Organization", job_tier: "Staff", job_class: "Staff",
      maintenance_team: false, maintenance_lead: false,
      updated_by: user, reports_to: bus_director)
    ap_manager = Organization::Position.create!(department: admin, organization: self, name: "AP Manager",
      rate_type: "Salary", authorized: Organization::Position::AUTHORIZED, authorization_level: "Organization", job_tier: "Staff", job_class: "Staff",
      maintenance_team: false, maintenance_lead: false,
      updated_by: user, reports_to: bus_director)
    gl_manager = Organization::Position.create!(department: admin, organization: self, name: "GL Manager",
      rate_type: "Salary", authorized: Organization::Position::AUTHORIZED, authorization_level: "Organization", job_tier: "Staff", job_class: "Staff",
      maintenance_team: false, maintenance_lead: false,
      updated_by: user, reports_to: bus_director)
    maint_dh = Organization::Position.create!(department: maint, organization: self, name: "Maintenance Department
      Head", rate_type: "Salary", authorized: Organization::Position::AUTHORIZED, authorization_level: "Organization",
      job_tier: "Staff", job_class: "Staff", maintenance_team: true, maintenance_lead: true,
      updated_by: user, reports_to: bus_director)
    tech_dh = Organization::Position.create!(department: maint, organization: self, name: "Technology Manager",
      rate_type: "Salary", authorized: Organization::Position::AUTHORIZED, authorization_level: "Organization",
      job_tier: "Staff", job_class: "Staff", maintenance_team: true, maintenance_lead: true,
      updated_by: user, reports_to: maint_dh)
    patch_dh = Organization::Position.create!(department: maint, organization: self, name: "Patch Maintenance Manager",
      rate_type: "Salary", authorized: Organization::Position::AUTHORIZED, authorization_level: "Organization",
      job_tier: "Staff", job_class: "Staff", maintenance_team: true, maintenance_lead: true,
      updated_by: user, reports_to: maint_dh)
    maint_crew_dh = Organization::Position.create!(department: maint, organization: self, name: "Maintenance Manager",
      rate_type: "Salary", authorized: Organization::Position::AUTHORIZED, authorization_level: "Organization",
      job_tier: "Staff", job_class: "Staff", maintenance_team: true, maintenance_lead: true,
      updated_by: user, reports_to: maint_dh)

    Organization::Position.create!(department: maint, organization: self, name: "Patch Maintenance",
      rate_type: "Hourly", authorized: Organization::Position::AUTHORIZED, authorization_level: "Organization",
      job_tier: "Staff", job_class: "Staff", maintenance_team: true, maintenance_lead: false,
      updated_by: user, reports_to: patch_dh)
    Organization::Position.create!(department: maint, organization: self, name: "Maintenance Technician",
      rate_type: "Hourly", authorized: Organization::Position::AUTHORIZED, authorization_level: "Organization",
      job_tier: "Staff", job_class: "Staff", maintenance_team: true, maintenance_lead: false,
      updated_by: user, reports_to: maint_crew_dh)
    Organization::Position.create!(department: maint, organization: self, name: "OTP",
      rate_type: "Hourly", authorized: Organization::Position::AUTHORIZED, authorization_level: "Organization",
      job_tier: "Staff", job_class: "Staff", maintenance_team: true, maintenance_lead: false,
      updated_by: user, reports_to: tech_dh)
    Organization::Position.create!(department: maint, organization: self, name: "Maintenance Admin",
      rate_type: "Hourly", authorized: Organization::Position::AUTHORIZED, authorization_level: "Organization",
      job_tier: "Staff", job_class: "Staff", maintenance_team: false, maintenance_lead: false,
      updated_by: user, reports_to: maint_dh)
    Organization::Position.create!(department: admin, organization: self, name: "HR Admin",
      rate_type: "Hourly", authorized: Organization::Position::AUTHORIZED, authorization_level: "Organization",
      job_tier: "Staff", job_class: "Staff", maintenance_team: false, maintenance_lead: false,
      updated_by: user, reports_to: hr_manager)
    Organization::Position.create!(department: admin, organization: self, name: "Payroll Admin",
      rate_type: "Hourly", authorized: Organization::Position::AUTHORIZED, authorization_level: "Organization",
      job_tier: "Staff", job_class: "Staff", maintenance_team: false, maintenance_lead: false,
      updated_by: user, reports_to: payroll_manager)

    Organization::Position.create!(department: admin, organization: self, name: "AP Admin",
      rate_type: "Hourly", authorized: Organization::Position::AUTHORIZED, authorization_level: "Organization",
      job_tier: "Staff", job_class: "Staff", maintenance_team: false, maintenance_lead: false,
      updated_by: user, reports_to: ap_manager)
    Organization::Position.create!(department: admin, organization: self, name: "GL Admin",
      rate_type: "Hourly", authorized: Organization::Position::AUTHORIZED, authorization_level: "Organization",
      job_tier: "Staff", job_class: "Staff", maintenance_team: false, maintenance_lead: false,
      updated_by: user, reports_to: gl_manager)

    director = Organization::Position.create!(department: admin, organization: self, name: "Director of Operations", rate_type:
      "Salary", reports_to: owner, authorized: Organization::Position::AUTHORIZED, authorization_level: "Organization",
      job_tier: "Staff", job_class: "Staff", maintenance_team: true, maintenance_lead: false,
      updated_by: user)
    training_manager = Organization::Position.create!(department: admin, organization: self, name: "Training Manager",
      rate_type: "Salary", authorized: Organization::Position::AUTHORIZED, authorization_level: "Organization", job_tier: "Staff", job_class: "Staff",
      maintenance_team: false, maintenance_lead: false,
      updated_by: user, reports_to: director)
    Organization::Position.create!(department: admin, organization: self, name: "Training Assistant",
      rate_type: "Hourly", authorized: Organization::Position::AUTHORIZED, authorization_level: "Organization",
      job_tier: "Staff", job_class: "Staff", maintenance_team: false, maintenance_lead: false,
      updated_by: user, reports_to: training_manager)
    om = Organization::Position.create!(department: ops, organization: self, name: "Operations Manager", rate_type: "Salary",
      reports_to: director, authorized: Organization::Position::AUTHORIZED, authorization_level: "Department",
      job_tier: "Above Restaurant", job_class: "Supervision", maintenance_team: true, maintenance_lead: false,
      updated_by: user)
    sup = Organization::Position.create!(department: ops, organization: self, name: "Supervisor", rate_type: "Salary",
      reports_to: om, authorized: Organization::Position::AUTHORIZED, authorization_level: "Department",
      job_tier: "Above Restaurant", job_class: "Supervision", maintenance_team: true, maintenance_lead: false,
      updated_by: user)
    gm = Organization::Position.create!(department: ops, organization: self, name: "General Manager", rate_type: "Salary",
      reports_to: sup, authorized: Organization::Position::AUTHORIZED, authorization_level: "Location",
      job_tier: "Restaurant", job_class: "Management", maintenance_team: false, maintenance_lead: false,
      updated_by: user)
    Organization::Position.create!(department: ops, organization: self, name: "Department Manager", rate_type: "Hourly",
      reports_to: gm, authorized: Organization::Position::AUTHORIZED, authorization_level: "Location",
      job_tier: "Restaurant", job_class: "Management", maintenance_team: false, maintenance_lead: false,
      updated_by: user)
    Organization::Position.create!(department: ops, organization: self, name: "Hourly Certified Manager", rate_type:
      "Hourly", reports_to: gm, authorized: Organization::Position::AUTHORIZED, authorization_level: "Location",
      job_tier: "Restaurant", job_class: "Management", maintenance_team: false, maintenance_lead: false,
      updated_by: user)
    Organization::Position.create!(department: ops, organization: self, name: "Floor Supervisor", rate_type: "Hourly",
      reports_to: gm, authorized: Organization::Position::AUTHORIZED, authorization_level: "Location",
      job_tier: "Restaurant", job_class: "Management", maintenance_team: false, maintenance_lead: false,
      updated_by: user)
    Organization::Position.create!(department: ops, organization: self, name: "Manager In Training", rate_type:
      "Hourly", reports_to: gm, authorized: Organization::Position::AUTHORIZED, authorization_level: "Location",
      job_tier: "Restaurant", job_class: "Management", maintenance_team: false, maintenance_lead: false,
      updated_by: user)
    Organization::Position.create!(department: ops, organization: self, name: "Crew", rate_type: "Hourly",
      reports_to: gm, authorized: Organization::Position::AUTHORIZED, authorization_level: "Location",
      job_tier: "Self", job_class: "Crew", maintenance_team: false, maintenance_lead: false,
      updated_by: user)
    Organization::Position.create!(department: ops, organization: self, name: "Crew Trainer", rate_type: "Hourly",
      reports_to: gm, authorized: Organization::Position::AUTHORIZED, authorization_level: "Location",
      job_tier: "Self", job_class: "Crew", maintenance_team: false, maintenance_lead: false,
      updated_by: user)
    Organization::Position.create!(department: ops, organization: self, name: "Primary Store Maintenance", rate_type:
      "Hourly", reports_to: gm, authorized: Organization::Position::AUTHORIZED, authorization_level: "Location",
      job_tier: "Self", job_class: "Crew", maintenance_team: false, maintenance_lead: false,
      updated_by: user)
    Organization::Position.create!(department: ops, organization: self, name: "Backup Store Maintenance", rate_type:
      "Hourly", reports_to: gm, authorized: Organization::Position::AUTHORIZED, authorization_level: "Location",
      job_tier: "Self", job_class: "Crew", maintenance_team: false, maintenance_lead: false,
      updated_by: user)
  end

  # def set_default_vendor
  #   Vendor.create(name: self.name, phone: self.phone, street: self.street, city: self.city, state: self.state, zip: self.zip)
  # end


  private

  def normalize_attributes
    self.name = name.to_s.split.map(&:capitalize).join(" ") if name.present?
    self.phone = format_phone(phone) if phone.present?
    self.eid = eid.to_s.downcase if eid.present?
    self.secondary_eids = secondary_eids.map { |e| e.to_s.downcase }.uniq.compact_blank if secondary_eids.is_a?(Array)
  end

  def format_phone(number)
    digits = number.to_s.gsub(/\D/, "")
    if digits.length == 10
      "#{digits[0..2]}-#{digits[3..5]}-#{digits[6..9]}"
    else
      number
    end
  end
end
