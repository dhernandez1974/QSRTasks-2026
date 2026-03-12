class OrganizationPolicy < ApplicationPolicy
  def show?
    authorized?(:organization, :organization, :Show)
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(id: user.organization_id)
      end
    end
  end
end
