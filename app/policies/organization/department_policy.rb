class Organization::DepartmentPolicy < ApplicationPolicy
  def index?
    authorized?(:organization, :department, :List)
  end

  def show?
    authorized?(:organization, :department, :Show)
  end

  def create?
    authorized?(:organization, :department, :Add)
  end

  def update?
    authorized?(:organization, :department, :Edit)
  end

  def destroy?
    authorized?(:organization, :department, :Remove)
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
