class Organization::Department < ApplicationRecord
  belongs_to :organization
  belongs_to :updated_by, class_name: "User"

  validates :name, presence: true
end
