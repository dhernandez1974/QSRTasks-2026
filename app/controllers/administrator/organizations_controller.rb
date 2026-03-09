class Administrator::OrganizationsController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_organization, only: %i[ show edit update destroy create_users sync_user_info ]

  # GET /administrator/organizations or /administrator/organizations.json
  def index
    @organizations = Organization.all
  end

  # GET /administrator/organizations/1 or /administrator/organizations/1.json
  def show
  end

  def create_users
    Datapass::CreateOrganizationUsersJob.perform_later(@organization.id)
    redirect_to administrator_organization_path(@organization), notice: "User creation job has been started."
  end

  def sync_user_info
    organization_ids = [ @organization.id ]
    if @organization.primary_operator?
      organization_ids += Organization.where(primary_eid: @organization.eid).where(primary_operator: false).pluck(:id)
    else
      if @organization.primary_eid.present?
        primary = Organization.find_by(eid: @organization.primary_eid, primary_operator: true)
        organization_ids << primary.id if primary
      end
    end

    Datapass::OrganizationUserInfoJob.perform_later(organization_ids: organization_ids.uniq)
    redirect_to administrator_organization_path(@organization), notice: "Organization user info sync job has been started."
  end

  # GET /administrator/organizations/new
  def new
    @organization = Organization.new
    @contact = User.new
  end

  # GET /administrator/organizations/1/edit
  def edit
    @contact = @organization.contact || User.new(organization: @organization)
  end

  # POST /administrator/organizations or /administrator/organizations.json
  def create
    @organization = Organization.new(organization_params)
    @contact = User.new(user_params)
    @contact.organization = @organization

    respond_to do |format|
      ActiveRecord::Base.transaction do
        if @organization.save && @contact.save
          format.html { redirect_to administrator_organization_path(@organization), notice: "Organization was successfully created." }
          format.json { render :show, status: :created, location: [:administrator, @organization] }
        else
          raise ActiveRecord::Rollback
        end
      end

      format.html { render :new, status: :unprocessable_entity }
      format.json { render json: { organization: @organization.errors, user: @contact.errors }, status: :unprocessable_entity }
    end
  end

  # PATCH/PUT /administrator/organizations/1 or /administrator/organizations/1.json
  def update
    respond_to do |format|
      if @organization.update(organization_params) && (@organization.contact&.update(user_params) || true)
        format.html { redirect_to administrator_organization_path(@organization), notice: "Organization was successfully updated." }
        format.json { render :show, status: :ok, location: [:administrator, @organization] }
      else
        @contact = @organization.contact || User.new(organization: @organization)
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @organization.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /administrator/organizations/1 or /administrator/organizations/1.json
  def destroy
    @organization.destroy!

    respond_to do |format|
      format.html { redirect_to administrator_organizations_path, notice: "Organization was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_organization
      @organization = Organization.find(params[:id])
    end

    def organization_params
      params.expect(organization: [ :name, :phone, :eid, :primary_eid, :street, :city, :state, :zip, :primary_operator ])
    end

    def user_params
      params.expect(user: [ :email, :password, :password_confirmation, :birth_date, :social, :eid, :geid, :payroll_id, :hire_date ])
    end
end
