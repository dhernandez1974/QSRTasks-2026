class Datapass::NewHire < ApplicationRecord
  belongs_to :organization
  belongs_to :location

  encrypts :ssn, :p, :e, :fn, :ln, :mn, :a, deterministic: true

  before_save :normalize_attributes

  private

  def normalize_attributes
    self.e = e.downcase if e.present?
    self.fn = fn.to_s.split.map(&:capitalize).join(' ') if fn.present?
    self.ln = ln.to_s.split.map(&:capitalize).join(' ') if ln.present?
    self.p = format_phone(p) if p.present?
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
