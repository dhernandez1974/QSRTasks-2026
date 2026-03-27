class Admin::MasqueradesController < Devise::MasqueradesController
  protected

    def after_masquerade_path_for(_resource)
      user_dashboard_path
    end

    def after_back_masquerade_path_for(_resource)
      user_dashboard_path
    end
end
