class Users::RegistrationsController < Devise::RegistrationsController
  # Override the sign_up method to handle role requests
  def sign_up(resource_name, resource)
    # Set role based on role_request, defaulting to parent
    requested_role = case resource.role_request
                     when 'teacher_request'
                       'teacher'
                     when 'parent_request'
                       'parent'
                     when 'staff_request'
                       'staff'
                     else
                       'parent' # default role
                     end
    resource.role = requested_role
    super
  end

  protected

  def update_resource_params
    devise_parameter_sanitizer.permit(:account_update, keys: [
      :name, :phone, :date_of_birth, :address, :avatar
    ])
  end
end