class Location < ApplicationRecord
  belongs_to :organization
  has_many :users
  has_and_belongs_to_many :users

  before_save :normalize_attributes
  validates :email, :phone, presence: true, uniqueness: { case_sensitive: false }

  private

  def normalize_attributes
    self.phone = format_phone(phone) if phone.present?
    self.email = email.to_s.downcase if email.present?
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
