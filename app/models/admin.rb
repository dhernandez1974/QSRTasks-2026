class Admin < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :validatable, :confirmable, :lockable, :timeoutable,
    :trackable

  before_save :normalize_attributes

  private

  def normalize_attributes
    self.email = email.to_s.downcase if email.present?
    self.first_name = first_name.to_s.split.map(&:capitalize).join(' ') if first_name.present?
    self.last_name = last_name.to_s.split.map(&:capitalize).join(' ') if last_name.present?
  end
end
