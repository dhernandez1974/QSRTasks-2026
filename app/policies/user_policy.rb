class UserPolicy < ApplicationPolicy
  def index?
    authorized?(:user, :list, :access)
  end

  def show?
    authorized?(:user, :show, :access)
  end

  def create?
    authorized?(:user, :add, :access)
  end

  def update?
    authorized?(:user, :edit, :access)
  end

  def destroy?
    authorized?(:user, :remove, :access)
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      elsif authorized?(:user, :list, :organization)
        scope.where(organization_id: user.organization_id)
      elsif authorized?(:user, :list, :department)
        scope.joins(:position).where(organization_positions: { department_id: user.position.department_id })
      elsif authorized?(:user, :list, :location)
        scope.where(location_id: user.location_id)
      else
        scope.where(id: user.id)
      end
    end
  end
end
