class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from Koala::Facebook::AuthenticationError, :with => :reset_and_go_to_root

  include NetworkHelper

  private

  def reset_and_go_to_root
    reset_session
    redirect_to root_url
  end

  def current_user
    @current_user ||= User.where({id: session[:user_id]}).first if session[:user_id]
  end

  def app_url
    URI::HTTP.build(Rails.application.config.url_options).to_s
  end

  helper_method :reset_and_go_to_root
  helper_method :current_user
  helper_method :app_url
end
