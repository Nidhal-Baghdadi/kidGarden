# Service object for handling attendance marking with notifications
class AttendanceService
  def initialize(student:, date:, status:, staff: nil, notes: nil)
    @student = student
    @date = date
    @status = status
    @staff = staff
    @notes = notes
  end

  def mark_attendance!
    ActiveRecord::Base.transaction do
      attendance = Attendance.create!(
        student: @student,
        date: @date,
        status: @status,
        staff: @staff,
        notes: @notes
      )
      
      # Enqueue notification job
      AttendanceNotificationJob.perform_later(@student.id, @date, @status)
      
      attendance
    end
  rescue ActiveRecord::RecordInvalid => e
    # Log error and potentially send to an error tracking service
    Rails.logger.error "Failed to mark attendance for student #{@student.id}: #{e.message}"
    raise e
  end
  
  # Check if student already has attendance for the given date
  def attendance_exists?
    Attendance.exists?(student: @student, date: @date)
  end
end