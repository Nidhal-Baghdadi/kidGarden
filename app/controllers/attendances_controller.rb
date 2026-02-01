class AttendancesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_attendance, only: [:show, :edit, :update, :destroy]

  def index
    @attendances =
      if current_user.admin?
        Attendance.includes(:student, :staff).order(date: :desc)
      elsif current_user.teacher?
        # attendance for students in classrooms taught by this teacher
        student_ids = Student.where(classroom_id: current_user.classrooms_taught.select(:id)).select(:id)
        Attendance.where(student_id: student_ids).includes(:student, :staff).order(date: :desc)
      elsif current_user.parent?
        # attendance for the parent's children
        student_ids = Student.where(parent_id: current_user.id).select(:id)
        Attendance.where(student_id: student_ids).includes(:student, :staff).order(date: :desc)
      elsif current_user.staff?
        # either records taken by staff OR (optionally) all records
        # choose one behavior:
        Attendance.where(staff_id: current_user.id).includes(:student, :staff).order(date: :desc)
      else
        Attendance.none
      end
  end

  def show
    unless can_access_attendance?(@attendance)
      redirect_to root_path, alert: "You don't have permission to view this attendance record."
      return
    end
  end

  def new
    @attendance = Attendance.new(date: Date.current)
  end

  def create
    @attendance = Attendance.new(attendance_params)
    @attendance.staff = current_user unless @attendance.staff_id.present?

    if @attendance.save
      redirect_to @attendance, notice: "Attendance was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
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
    unless current_user.admin? || current_user.teacher? || current_user.staff?
      redirect_to root_path, alert: "You don't have permission to update this attendance record."
      return
    end

    unless can_access_attendance?(@attendance)
      redirect_to root_path, alert: "You don't have permission to update this attendance record."
      return
    end

    if @attendance.update(attendance_params)
      redirect_to @attendance, notice: "Attendance was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    unless current_user.admin? || current_user.teacher? || current_user.staff?
      redirect_to root_path, alert: "You don't have permission to delete this attendance record."
      return
    end

    unless can_access_attendance?(@attendance)
      redirect_to root_path, alert: "You don't have permission to delete this attendance record."
      return
    end

    @attendance.destroy
    redirect_to attendances_path, notice: "Attendance was successfully deleted."
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
