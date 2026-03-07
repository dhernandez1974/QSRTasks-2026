class HrSsn < ApplicationRecord
  belongs_to :organization

  encrypts :geid, :ssn, deterministic: true
  validates :geid, presence: true
  validates :ssn, presence: true

  before_save :normalize_attributes

  private

  def normalize_attributes
    self.geid = geid.to_s.downcase if geid.present?
  end
end
