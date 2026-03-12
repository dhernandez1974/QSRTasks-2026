class Organization::OrganizationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization, only: %i[ show ]
  before_action :verify_organization_association, only: %i[ show ]

  # GET /organization/organizations/1
  def show
    authorize @organization
  end

  private

  def set_organization
    @organization = Organization.find(params[:id])
  end

  def verify_organization_association
    unless current_user.organization_id == @organization.id
      redirect_to root_path, alert: "You are not authorized to view this organization's details."
    end
  end
end
