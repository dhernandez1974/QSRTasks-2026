class Organization::Comment < ApplicationRecord
  self.table_name = "comments"

  belongs_to :location, class_name: "Organization::Location"
  belongs_to :organization
  belongs_to :employee_named, class_name: "User", optional: true
  belongs_to :user
end
