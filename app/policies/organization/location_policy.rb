class Organization::LocationPolicy < ApplicationPolicy
  def index?
    authorized?(:organization, :location, :List)
  end

  def show?
    authorized?(:organization, :location, :Show)
  end

  def create?
    authorized?(:organization, :location, :Add)
  end

  def update?
    authorized?(:organization, :location, :Edit)
  end

  def destroy?
    authorized?(:organization, :location, :Remove)
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      elsif authorized?(:organization, :location, :List)
        # Check authorization level or other constraints if needed
        # For now, base it on organization
        scope.where(organization_id: user.organization_id)
      else
        scope.where(id: user.location_id)
      end
    end
  end
end
