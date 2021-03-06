# frozen_string_literal: true
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_locale

  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def unverified_controller?
    devise_controller? || admin_controller? || errors_controller?
  end

  def admin_controller?
    is_a?(ActiveAdmin::BaseController)
  end

  def errors_controller?
    controller_name == "errors"
  end

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(:back)
  rescue ActionController::RedirectBackError
    redirect_to root_path
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options
    { locale: I18n.locale == I18n.default_locale ? nil : I18n.locale }
  end

  protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up) do |u|
        u.permit(:first_name, :last_name, :email, :password, :password_confirmation)
      end
    end
end
