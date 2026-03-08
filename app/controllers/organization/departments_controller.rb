class Organization::DepartmentsController < ApplicationController
  before_action :set_organization_department, only: %i[ show edit update destroy ]

  # GET /organization/departments or /organization/departments.json
  def index
    @organization_departments = Organization::Department.all
  end

  # GET /organization/departments/1 or /organization/departments/1.json
  def show
  end

  # GET /organization/departments/new
  def new
    @organization_department = Organization::Department.new
  end

  # GET /organization/departments/1/edit
  def edit
  end

  # POST /organization/departments or /organization/departments.json
  def create
    @organization_department = Organization::Department.new(organization_department_params)

    respond_to do |format|
      if @organization_department.save
        format.html { redirect_to organization_department_path(@organization_department), notice: "Department was successfully created." }
        format.json { render :show, status: :created, location: @organization_department }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @organization_department.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /organization/departments/1 or /organization/departments/1.json
  def update
    respond_to do |format|
      if @organization_department.update(organization_department_params)
        format.html { redirect_to organization_department_path(@organization_department), notice: "Department was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @organization_department }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @organization_department.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /organization/departments/1 or /organization/departments/1.json
  def destroy
    @organization_department.destroy!

    respond_to do |format|
      format.html { redirect_to organization_departments_path, notice: "Department was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_organization_department
      @organization_department = Organization::Department.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def organization_department_params
      params.expect(organization_department: [ :organization_id, :name, :updated_by_id ])
    end
end
