class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :validatable, :confirmable, :lockable, :timeoutable,
    :trackable, :masqueradable


  belongs_to :organization, optional: true
  belongs_to :location, class_name: "Organization::Location", optional: true
  belongs_to :position, class_name: "Organization::Position", optional: true
  has_and_belongs_to_many :locations, class_name: "Organization::Location"

  encrypts :social, :eid, :geid, :phone_number, :first_name, :last_name, :payroll_id, deterministic: true

  before_save :normalize_attributes
  validates :phone_number, uniqueness: true, allow_nil: true

  def admin?
    admin == true
  end

  private

  def normalize_attributes
    self.email = email.to_s.downcase if email.present?
    self.first_name = first_name.to_s.split.map(&:capitalize).join(' ') if first_name.present?
    self.last_name = last_name.to_s.split.map(&:capitalize).join(' ') if last_name.present?
    self.phone_number = format_phone(phone_number) if phone_number.present?
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
