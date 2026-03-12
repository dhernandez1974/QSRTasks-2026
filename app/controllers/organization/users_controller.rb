class Organization::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: %i[ show edit update destroy ]

  def index
    @users = policy_scope(current_user.organization.users)
             .includes(:position, :location)
             .left_outer_joins(:position)
             .order("organization_positions.name ASC, users.last_name ASC")
  end

  def show
    authorize @user
  end

  def new
    @user = current_user.organization.users.build
    authorize @user
  end

  def edit
    authorize @user
  end

  def create
    @user = current_user.organization.users.build(user_params)
    authorize @user

    if @user.save
      redirect_to organization_user_path(@user), notice: "User was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @user
    if @user.update(user_params)
      redirect_to organization_user_path(@user), notice: "User was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @user
    @user.destroy
    redirect_to organization_users_path, notice: "User was successfully destroyed.", status: :see_other
  end

  private

  def set_user
    @user = current_user.organization.users.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :phone_number, :password, :password_confirmation, :location_id, :position_id)
  end
end
