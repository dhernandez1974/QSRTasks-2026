class DashboardController < ApplicationController
  before_action :authenticate_admin!, only: :admin
  before_action :authenticate_user!, only: :user

  def admin
  end

  def user
  end

  def applicant
  end
end
