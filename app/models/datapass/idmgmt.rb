class Datapass::Idmgmt < ApplicationRecord
  belongs_to :organization
  belongs_to :location

  encrypts :geid, :email, :first_name, :last_name, :middle_initial, deterministic: true

  before_save :normalize_attributes

  private

  def normalize_attributes
    self.email = email.to_s.downcase if email.present?
    self.first_name = first_name.to_s.split.map(&:capitalize).join(' ') if first_name.present?
    self.last_name = last_name.to_s.split.map(&:capitalize).join(' ') if last_name.present?
    self.middle_initial = middle_initial.to_s.split.map(&:capitalize).join(' ') if middle_initial.present?
    self.geid = geid.to_s.downcase if geid.present?
  end
end
