class AttendancesController < ApplicationController
  before_action :set_attendance, only: [:show, :edit, :update, :destroy]

  def index
    respond_to do |format|
      format.html
      format.json { render json: AttendancesDatatable.new(params, view_context: view_context) }
    end
  end

  def show
    # Allow access based on role
    unless can_access_attendance?(@attendance)
      redirect_to root_path, alert: "You don't have permission to view this attendance record."
      return
    end
  end

  def new
    @attendance = Attendance.new
  end

  def create
    @attendance = Attendance.new(attendance_params)
    # Set staff to current user if not already set
    @attendance.staff = current_user unless @attendance.staff_id.present?

    if @attendance.save
      redirect_to @attendance, notice: 'Attendance was successfully created.'
    else
      render :new
    end
  end

  def edit
    # Only teachers and staff can edit attendance
    unless current_user.admin? || current_user.teacher? || current_user.staff?
      redirect_to root_path, alert: "You don't have permission to edit this attendance record."
      return
    end

    unless can_access_attendance?(@attendance)
      redirect_to root_path, alert: "You don't have permission to edit this attendance record."
      return
    end
  end

  def update
    # Only teachers and staff can update attendance
    unless current_user.admin? || current_user.teacher? || current_user.staff?
      redirect_to root_path, alert: "You don't have permission to update this attendance record."
      return
    end

    unless can_access_attendance?(@attendance)
      redirect_to root_path, alert: "You don't have permission to update this attendance record."
      return
    end

    if @attendance.update(attendance_params)
      redirect_to @attendance, notice: 'Attendance was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    # Only teachers and staff can delete attendance records
    unless current_user.admin? || current_user.teacher? || current_user.staff?
      redirect_to root_path, alert: "You don't have permission to delete this attendance record."
      return
    end

    unless can_access_attendance?(@attendance)
      redirect_to root_path, alert: "You don't have permission to delete this attendance record."
      return
    end

    @attendance.destroy
    redirect_to attendances_url, notice: 'Attendance was successfully deleted.'
  end

  private

  def set_attendance
    @attendance = Attendance.find(params[:id])
  end

  def attendance_params
    params.require(:attendance).permit(:student_id, :date, :status, :notes, :staff_id)
  end

  def can_access_attendance?(attendance)
    return false unless attendance.student

    current_user.admin? ||
    (current_user.teacher? && attendance.student.classroom && attendance.student.classroom.teacher == current_user) ||
    (current_user.parent? && attendance.student.parent == current_user) ||
    (current_user.staff? && attendance.staff == current_user)
  end
end
