class Organization::CommentPolicy < ApplicationPolicy
  def index?
    true # For now, allow all authenticated users
  end

  def show?
    true
  end

  def create?
    true
  end

  def update?
    true
  end

  def destroy?
    true
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
