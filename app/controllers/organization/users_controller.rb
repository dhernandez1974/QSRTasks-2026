class Organization::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: %i[ show edit update destroy ]

  def index
    @users = current_user.organization.users
  end

  def show
  end

  def new
    @user = current_user.organization.users.build
  end

  def edit
  end

  def create
    @user = current_user.organization.users.build(user_params)

    if @user.save
      redirect_to organization_user_path(@user), notice: "User was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @user.update(user_params)
      redirect_to organization_user_path(@user), notice: "User was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
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
