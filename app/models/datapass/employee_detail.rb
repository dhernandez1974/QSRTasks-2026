class Datapass::EmployeeDetail < ApplicationRecord
  belongs_to :organization
  belongs_to :location

  encrypts :payroll_id, :eid, :geid, :email, :first_name, :last_name, :primary_phone, :birth_date, deterministic: true

  before_save :normalize_attributes

  private

    def normalize_attributes
      self.email = email.to_s.downcase if email.present?
      self.first_name = first_name.to_s.split.map(&:capitalize).join(' ') if first_name.present?
      self.last_name = last_name.to_s.split.map(&:capitalize).join(' ') if last_name.present?
      self.primary_phone = format_phone(primary_phone) if primary_phone.present?
      self.geid = geid.to_s.downcase if geid.present?
      self.eid = eid.to_s.downcase if eid.present?
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
