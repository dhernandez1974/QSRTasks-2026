class Organization < ApplicationRecord
  has_one :contact, -> { where(admin: true) }, class_name: "User", dependent: :destroy
  has_many :users, dependent: :destroy
  has_many :hr_ssns, class_name: "Datapass::HrSsn", dependent: :destroy
  has_many :employee_histories, class_name: "Datapass::EmployeeHistory", dependent: :destroy
  has_many :locations, class_name: "Organization::Location", dependent: :destroy

  encrypts :eid, deterministic: true

  validates :name, :phone, :eid, :street, :city, :state, :zip, presence: true
  validates :primary_operator, inclusion: { in: [ true, false ] }

  before_save :normalize_attributes
  # after_create :set_default_departments
  # after_create :set_default_vendor

  def full_address
    self.street + ", " + self.city + ", " + self.state + " " + self.zip
  end

  def set_default_departments
    user = self.contact || User.find_by(organization_id: self.id)

    ops = Organization::Department.create(name: "Operations", organization: self, updated_by: user)
    admin = Organization::Department.create(name: "Administration", organization: self, updated_by: user)
    maint = Organization::Department.create(name: "Maintenance", organization: self, updated_by: user)
    
    owner = Organization::Position.create(department: admin, organization: self, name: "Owner", rate_type: "Salary",
      authorized: Organization::Position::AUTHORIZED, authorization_level: "Organization", job_tier: "Staff", job_class: "Staff",
      maintenance_team: true, maintenance_lead: false,
      updated_by: user)
    director = Organization::Position.create(department: admin, organization: self, name: "Director of Operations", rate_type:
      "Salary", reports_to: admin, authorized: Organization::Position::AUTHORIZED, authorization_level: "Organization",
      job_tier: "Staff", job_class: "Staff", maintenance_team: true, maintenance_lead: false,
      updated_by: user)
    om = Organization::Position.create(department: ops, organization: self, name: "Operations Manager", rate_type: "Salary",
      reports_to: admin, authorized: Organization::Position::AUTHORIZED, authorization_level: "Department",
      job_tier: "Above Restaurant", job_class: "Supervision", maintenance_team: true, maintenance_lead: false,
      updated_by: user)
    sup = Organization::Position.create(department: ops, organization: self, name: "Supervisor", rate_type: "Salary",
      reports_to: ops, authorized: Organization::Position::AUTHORIZED, authorization_level: "Department",
      job_tier: "Above Restaurant", job_class: "Supervision", maintenance_team: true, maintenance_lead: false,
      updated_by: user)
    gm = Organization::Position.create(department: ops, organization: self, name: "General Manager", rate_type: "Salary",
      reports_to: ops, authorized: Organization::Position::AUTHORIZED, authorization_level: "Location",
      job_tier: "Restaurant", job_class: "Management", maintenance_team: false, maintenance_lead: false,
      updated_by: user)
    Organization::Position.create(department: ops, organization: self, name: "Department Manager", rate_type: "Hourly",
      reports_to: ops, authorized: Organization::Position::AUTHORIZED, authorization_level: "Location",
      job_tier: "Restaurant", job_class: "Management", maintenance_team: false, maintenance_lead: false,
      updated_by: user)
    Organization::Position.create(department: ops, organization: self, name: "Manager", rate_type: "Hourly",
      reports_to: ops, authorized: Organization::Position::AUTHORIZED, authorization_level: "Location",
      job_tier: "Restaurant", job_class: "Management", maintenance_team: false, maintenance_lead: false,
      updated_by: user)
    Organization::Position.create(department: ops, organization: self, name: "Crew", rate_type: "Hourly",
      reports_to: ops, authorized: Organization::Position::AUTHORIZED, authorization_level: "Location",
      job_tier: "Self", job_class: "Crew", maintenance_team: false, maintenance_lead: false,
      updated_by: user)
    Organization::Position.create(department: ops, organization: self, name: "Store Maintenance", rate_type: "Hourly",
      reports_to: ops, authorized: Organization::Position::AUTHORIZED, authorization_level: "Location",
      job_tier: "Self", job_class: "Crew", maintenance_team: false, maintenance_lead: false,
      updated_by: user)
  end

  # def set_default_vendor
  #   Vendor.create(name: self.name, phone: self.phone, street: self.street, city: self.city, state: self.state, zip: self.zip)
  # end


  private

  def normalize_attributes
    self.name = name.to_s.split.map(&:capitalize).join(' ') if name.present?
    self.phone = format_phone(phone) if phone.present?
    self.eid = eid.to_s.downcase if eid.present?
    self.primary_eid = primary_eid.to_s.downcase if primary_eid.present?
  end

  def format_phone(number)
    digits = number.to_s.gsub(/\D/, '')
    if digits.length == 10
      "#{digits[0..2]}-#{digits[3..5]}-#{digits[6..9]}"
    else
      number
    end
  end
end
