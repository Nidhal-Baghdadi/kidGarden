class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user!
  before_action :check_approval_status
  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActionController::ParameterMissing, with: :parameter_missing

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :role_request])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :phone, :date_of_birth, :address, :avatar])
  end

  private

  def check_approval_status
    # Skip approval check for Devise controllers and registration controllers
    return if devise_controller? || controller_name == 'registrations' || controller_name == 'admin/registrations'

    # Check if user is signed in and handle potential RecordNotFound error
    begin
      if user_signed_in? && current_user&.unapproved?
        sign_out current_user
        redirect_to root_path, alert: "Your account is pending approval. You will be notified when approved."
      end
    rescue ActiveRecord::RecordNotFound
      # User record was deleted, sign out and redirect to login
      sign_out if user_signed_in?
      redirect_to new_user_session_path, alert: "Your account may have been removed. Please sign in again."
    end
  end

  def record_not_found
    # Log the error for debugging
    Rails.logger.error "RecordNotFound error occurred at: #{request.path}, params: #{params.inspect}"

    # Check if this might be an authentication issue
    begin
      if user_signed_in? && current_user&.id
        # Try to access the user record to see if it exists
        user_exists = User.exists?(current_user.id)
        unless user_exists
          # User record was deleted, sign out and redirect to login
          sign_out if user_signed_in?
          redirect_to new_user_session_path, alert: "Your account may have been removed. Please sign in again."
          return
        end
      end
    rescue ActiveRecord::RecordNotFound
      # User record definitely doesn't exist
      sign_out if user_signed_in?
      redirect_to new_user_session_path, alert: "Your account may have been removed. Please sign in again."
      return
    end

    # For other RecordNotFound errors, redirect to root
    redirect_to root_path, alert: "Record not found."
  end

    def parameter_missing

      redirect_to root_path, alert: "Invalid request parameters."

    end

  

    def view_context

      super.tap do |vc|

        vc.class.include(ApplicationHelper)

        vc.class.include(Rails.application.routes.url_helpers)

      end

    end

  end

  