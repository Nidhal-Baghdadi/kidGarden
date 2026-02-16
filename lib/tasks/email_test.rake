namespace :emails do
  desc "Send test OTP email"
  task test_otp: :environment do
    user = User.first || User.create!(
      email: 'test@example.com',
      password: 'password123',
      name: 'Test User',
      role: 'parent'
    )
    
    puts "Sending test OTP email to #{user.email}..."
    otp = user.generate_otp
    puts "OTP sent: #{otp}"
  end
  
  desc "Send test notification email"
  task test_notification: :environment do
    user = User.first || User.create!(
      email: 'test@example.com',
      password: 'password123',
      name: 'Test User',
      role: 'parent'
    )
    
    student = Student.first || Student.create!(
      first_name: 'John',
      last_name: 'Doe',
      date_of_birth: 5.years.ago,
      parent: user
    )
    
    attendance = Attendance.create!(
      student: student,
      date: Date.current,
      status: :present,
      staff: User.where(role: 'teacher').first || user
    )
    
    puts "Sending test attendance notification..."
    NotificationService.send_attendance_notification(attendance)
    puts "Attendance notification sent!"
  end
end