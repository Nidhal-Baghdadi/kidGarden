class Admin::RegistrationsController < ApplicationController
  before_action :ensure_admin
  before_action :set_registration, only: %i[show approve reject]

  def index
    @registrations = User.where(approved: false).order(created_at: :desc)
  end

  def show
  end

  def approve
    @registration.approve!

    role_to_assign =
      case @registration.role_request
      when "teacher_request" then "teacher"
      when "parent_request"  then "parent"
      when "staff_request"   then "staff"
      else "parent"
      end

    @registration.update!(role: role_to_assign)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to admin_registrations_path, notice: "Registration approved successfully!" }
    end
  end

  def reject
    @registration.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to admin_registrations_path, notice: "Registration rejected and user deleted." }
    end
  end

  private

  def set_registration
    @registration = User.find(params[:id])
  end

  def ensure_admin
    redirect_to root_path unless current_user&.admin?
  end
end
