class User::MasqueradesController < Devise::MasqueradesController
  protected

  def masquerade_authorize!
    unless current_user&.admin?
      redirect_to root_path, alert: "Not authorized"
    end
  end

  def after_masquerade_path_for(resource)
    root_path
  end

  def masquerade_owner
    current_user
  end

  def session_key(mapping = nil, owner = nil)
    owner_id = case owner
               when String, Integer then owner
               else owner.respond_to?(:id) ? owner.id : nil
               end
    owner_id ||= masquerade_owner&.id
    "devise_masquerade_user_#{owner_id}" if owner_id
  end
end
