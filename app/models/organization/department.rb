class Organization::Department < ApplicationRecord
  belongs_to :organization
  belongs_to :updated_by, class_name: "User", optional: true
  has_many :positions, class_name: "Organization::Position", foreign_key: "department_id", dependent: :destroy

  validates :name, presence: true
end
