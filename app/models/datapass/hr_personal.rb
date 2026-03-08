class Datapass::HrPersonal < ApplicationRecord
  self.table_name = "datapass_hr_personals"
  belongs_to :organization
  belongs_to :location, class_name: "Organization::Location"

  encrypts :payroll_id, :geid, :email_address, :first_name, :last_name, :cell_phone_number, deterministic: true

  before_save :normalize_attributes

  private

    def normalize_attributes
      self.email_address = email_address.to_s.downcase if email_address.present?
      self.first_name = first_name.to_s.split.map(&:capitalize).join(' ') if first_name.present?
      self.last_name = last_name.to_s.split.map(&:capitalize).join(' ') if last_name.present?
      self.cell_phone_number = format_phone(cell_phone_number) if cell_phone_number.present?
      self.geid = geid.to_s.downcase if geid.present?
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
