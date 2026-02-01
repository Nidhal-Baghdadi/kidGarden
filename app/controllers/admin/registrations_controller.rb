class Admin::RegistrationsController < ApplicationController
  before_action :ensure_admin

  def index
    respond_to do |format|
      format.html
      format.json { render json: Admin::RegistrationsDatatable.new(params, view_context: view_context) }
    end
  end

  def show
    @registration = User.find(params[:id])
  end

  def approve
    @registration = User.find(params[:id])
    @registration.approve!

    # Map the role_request to the actual role
    role_to_assign = case @registration.role_request
                     when 'teacher_request'
                       'teacher'
                     when 'parent_request'
                       'parent'
                     when 'staff_request'
                       'staff'
                     else
                       'parent' # default role
                     end
    @registration.update!(role: role_to_assign)

    # In a real app, you would send an email to the user
    redirect_to admin_registrations_path, notice: "Registration approved successfully!"
  end

  def reject
    @registration = User.find(params[:id])
    @registration.destroy

    redirect_to admin_registrations_path, notice: "Registration rejected and user deleted."
  end

  private

  def ensure_admin
    redirect_to root_path unless current_user&.admin?
  end
end