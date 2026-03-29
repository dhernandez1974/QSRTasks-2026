class Organization::PositionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization_position, only: %i[ show edit update destroy ]

  # GET /organization/positions
  def index
    @organization_positions = policy_scope(Organization::Position.all)
  end

  # GET /organization/positions/1
  def show
    authorize @organization_position
  end

  # GET /organization/positions/new
  def new
    @organization_position = Organization::Position.new(organization: current_user.organization)
    authorize @organization_position
  end

  # GET /organization/positions/1/edit
  def edit
    authorize @organization_position
  end

  # POST /organization/positions
  def create
    @organization_position = Organization::Position.new(organization_position_params)
    authorize @organization_position

    if @organization_position.save
      redirect_to organization_position_path(@organization_position), notice: "Position was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /organization/positions/1
  def update
    authorize @organization_position
    if @organization_position.update(organization_position_params)
      redirect_to organization_position_path(@organization_position), notice: "Position was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /organization/positions/1
  def destroy
    authorize @organization_position
    @organization_position.destroy!
    redirect_to organization_positions_path, notice: "Position was successfully destroyed.", status: :see_other
  end

  private

  def set_organization_position
    @organization_position = Organization::Position.find(params[:id])
  end

  def organization_position_params
    params.require(:organization_position).permit(
      :department_id, :organization_id, :name, :rate_type, :reports_to_id, 
      :authorization_level, :job_tier, :job_class, :maintenance_team, 
      :maintenance_lead, :updated_by_id,
      authorized: {}
    ).tap do |whitelisted|
      whitelisted[:updated_by_id] = current_user.id
    end
  end
end
