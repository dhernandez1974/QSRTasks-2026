class Datapass::Identification < ApplicationRecord
  self.table_name = "datapass_identifications"
  belongs_to :organization
  belongs_to :location, class_name: "Organization::Location"

  encrypts :geid, :email_address, :ssn, :first_name, :last_name, deterministic: true

  before_save :normalize_attributes

  private

    def normalize_attributes
      self.email_address = email_address.to_s.downcase if email_address.present?
      self.first_name = first_name.to_s.split.map(&:capitalize).join(' ') if first_name.present?
      self.last_name = last_name.to_s.split.map(&:capitalize).join(' ') if last_name.present?
      self.geid = geid.to_s.downcase if geid.present?
    end

end
