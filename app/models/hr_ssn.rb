class HrSsn < ApplicationRecord
  belongs_to :organization

  encrypts :eid, :ssn, deterministic: true
  validates :eid, presence: true
  validates :ssn, presence: true

  before_save :normalize_attributes

  private

  def normalize_attributes
    self.eid = eid.to_s.downcase if eid.present?
  end
end
