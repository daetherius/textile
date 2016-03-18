class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def after_sign_in_path_for(resource)
    # TODO update to users#dashboard
    current_user.admin? ? users_path : edit_user_registration_path
  end

end
