class Datapass::EmployeeHistory < ApplicationRecord
  belongs_to :organization
  belongs_to :location, class_name: "Organization::Location"
end
