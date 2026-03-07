class OrganizationsController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_organization, only: %i[ show edit update destroy ]

  # GET /organizations or /organizations.json
  def index
    @organizations = Organization.all
  end

  # GET /organizations/1 or /organizations/1.json
  def show
  end

  # GET /organizations/new
  def new
    @organization = Organization.new
    @contact = User.new
  end

  # GET /organizations/1/edit
  def edit
    @contact = @organization.contact
  end

  # POST /organizations or /organizations.json
  def create
    @organization = Organization.new(organization_params)
    @contact = User.new(user_params)
    @contact.organization = @organization

    # For new user creation in Devise, we might need some default password or handle it
    # The requirement says "the user will be a new user".
    # Since User is a Devise model, it usually requires email and password.
    
    respond_to do |format|
      # We need to save both. Wrapping in a transaction is good practice.
      ActiveRecord::Base.transaction do
        if @organization.save && @contact.save
          format.html { redirect_to organization_url(@organization), notice: "Organization was successfully created." }
          format.json { render :show, status: :created, location: @organization }
        else
          raise ActiveRecord::Rollback
        end
      end

      # If it falls through the transaction (rollback or didn't save)
      format.html { render :new, status: :unprocessable_entity }
      format.json { render json: { organization: @organization.errors, user: @contact.errors }, status: :unprocessable_entity }
    end
  end

  # PATCH/PUT /organizations/1 or /organizations/1.json
  def update
    respond_to do |format|
      if @organization.update(organization_params) && @organization.contact.update(user_params)
        format.html { redirect_to organization_url(@organization), notice: "Organization was successfully updated." }
        format.json { render :show, status: :ok, location: @organization }
      else
        @contact = @organization.contact
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @organization.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /organizations/1 or /organizations/1.json
  def destroy
    @organization.destroy!

    respond_to do |format|
      format.html { redirect_to organizations_url, notice: "Organization was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_organization
      @organization = Organization.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def organization_params
      params.expect(organization: [ :name, :phone, :eid, :primary_eid, :street, :city, :state, :zip, :primary_operator ])
    end

    def user_params
      params.expect(user: [ :email, :password, :password_confirmation ])
    end
end
