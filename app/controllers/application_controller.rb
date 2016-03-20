class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token, if: :json_request?

  def after_sign_in_path_for(resource)
    dashboard_path
  end

  protected

  def json_request?
    request.format.json?
  end

  def json_with_status(status = :ok, message = nil)
    response = {}
    status_code = Rack::Utils::status_code status

    if message.blank?
      response = {nothing: true, status: status}
    else
      response = {json: { error: message, status: status_code }, status: status}
    end

    response
  end
end
