class Organization::PositionPolicy < ApplicationPolicy
  def index?
    authorized?(:organization, :position, :List)
  end

  def show?
    authorized?(:organization, :position, :Show)
  end

  def create?
    authorized?(:organization, :position, :Add)
  end

  def update?
    authorized?(:organization, :position, :Edit)
  end

  def destroy?
    authorized?(:organization, :position, :Remove)
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(organization_id: user.organization_id)
      end
    end
  end
end
