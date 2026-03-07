class Organization < ApplicationRecord
  has_one :contact, class_name: "User", dependent: :destroy
  has_many :hr_ssns, dependent: :destroy
  has_many :locations, dependent: :destroy

  encrypts :eid, deterministic: true

  validates :name, :phone, :eid, :street, :city, :state, :zip, presence: true
  validates :primary_operator, inclusion: { in: [ true, false ] }

  before_save :normalize_attributes

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
