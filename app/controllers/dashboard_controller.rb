class DashboardController < ApplicationController
  def index
    if current_user.admin?
      # Admin sees all data
      @recent_students = Student.includes(:classroom).order(created_at: :desc).limit(5)
      @todays_attendance = Attendance.includes(:student).where(date: Date.current).limit(5)
    elsif current_user.teacher?
      # Teacher sees only their classroom's data
      classroom_ids = current_user.classrooms_taught.ids
      @recent_students = Student.includes(:classroom).where(classroom_id: classroom_ids).order(created_at: :desc).limit(5)
      @todays_attendance = Attendance.joins(:student).where(students: { classroom_id: classroom_ids }, date: Date.current).limit(5)
    elsif current_user.parent?
      # Parent sees only their children's data
      student_ids = current_user.students_as_parent.ids
      @recent_students = Student.includes(:classroom).where(id: student_ids).order(created_at: :desc).limit(5)
      @todays_attendance = Attendance.where(student_id: student_ids, date: Date.current).limit(5)
    else
      # Other roles - default to empty sets
      @recent_students = Student.none
      @todays_attendance = Attendance.none
    end
  end
end
