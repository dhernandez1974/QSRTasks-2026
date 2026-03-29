class Organization::PositionPolicy < ApplicationPolicy
  def index?
    user.admin? || authorized?(:organization, :position, :List)
  end

  def show?
    user.admin? || authorized?(:organization, :position, :Show)
  end

  def create?
    user.admin? || authorized?(:organization, :position, :Add)
  end

  def update?
    user.admin? || authorized?(:organization, :position, :Edit)
  end

  def destroy?
    user.admin? || authorized?(:organization, :position, :Remove)
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
