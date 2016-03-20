class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token, if: :json_request?

  def after_sign_in_path_for(resource)
    current_user.admin? ? users_path : dashboard_path
  end

  protected

  def json_request?
    request.format.json?
  end
end
