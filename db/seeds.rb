# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Seeding database with sample data..."

# Clear existing data to avoid conflicts
puts "Clearing existing data..."
Attendance.delete_all
Fee.delete_all
ParentStudentRelationship.delete_all
Student.delete_all
Classroom.delete_all
Event.delete_all
Notification.delete_all
Resource.delete_all
Curriculum.delete_all
User.delete_all

# Create Admin User
puts "Creating admin account..."
admin = User.create!(
  name: "Admin User",
  email: "admin@kidgarden.com",
  password: "Password123!",
  password_confirmation: "Password123!",
  role: :admin,
  status: :active,
  approved: true,
  approved_at: Time.current
)

# Create Staff Accounts
puts "Creating staff accounts..."
staff_users = []
5.times do |i|
  staff_users << User.create!(
    name: "Staff #{i+1}",
    email: "staff#{i+1}@kidgarden.com",
    password: "Password123!",
    password_confirmation: "Password123!",
    role: :staff,
    status: :active,
    approved: true,
    approved_at: Time.current
  )
end

# Create Teacher Accounts
puts "Creating teacher accounts..."
teacher_users = []
3.times do |i|
  teacher_users << User.create!(
    name: "Teacher #{i+1}",
    email: "teacher#{i+1}@kidgarden.com",
    password: "Password123!",
    password_confirmation: "Password123!",
    role: :teacher,
    status: :active,
    approved: true,
    approved_at: Time.current
  )
end

# Create Parent Accounts
puts "Creating parent accounts..."
parent_users = []
10.times do |i|
  parent_users << User.create!(
    name: "Parent #{i+1}",
    email: "parent#{i+1}@kidgarden.com",
    password: "Password123!",
    password_confirmation: "Password123!",
    role: :parent,
    status: :active,
    approved: true,
    approved_at: Time.current
  )
end

# Create Classrooms
puts "Creating classrooms..."
classrooms = []
classroom_names = ["Sunflower Class", "Butterfly Class", "Rainbow Class", "Ocean Class", "Space Class"]

classroom_names.each_with_index do |name, i|
  classrooms << Classroom.create!(
    name: name,
    capacity: 20,
    description: "Classroom for #{name}",
    schedule: "Monday-Friday, 9:00 AM - 3:00 PM",
    teacher: teacher_users[i % teacher_users.length]
  )
end

# Create Students
puts "Creating students..."
students = []
first_names = ["Emma", "Liam", "Olivia", "Noah", "Ava", "William", "Sophia", "James", "Isabella", "Benjamin", "Mia", "Elijah", "Charlotte", "Lucas", "Amelia", "Mason", "Harper", "Logan", "Evelyn", "Alexander"]
last_names = ["Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis", "Rodriguez", "Martinez", "Hernandez", "Lopez", "Gonzalez", "Wilson", "Anderson", "Thomas", "Taylor", "Moore", "Jackson", "White"]

20.times do |i|
  students << Student.create!(
    first_name: first_names[i],
    last_name: last_names[i],
    date_of_birth: rand(4.years.ago..2.years.ago),
    enrollment_date: rand(6.months.ago..1.month.ago),
    status: :enrolled,
    gender: [:male, :female, :other].sample,
    emergency_contact_name: "Parent #{i+1}",
    emergency_contact_phone: "+1-555-#{rand(100..999)}-#{rand(1000..9999)}",
    medical_information: i.even? ? "No medical conditions" : "Allergic to nuts",
    parent: parent_users[i % parent_users.length],
    classroom: classrooms[i % classrooms.length]
  )
end

# Create Parent-Student Relationships
puts "Creating parent-student relationships..."
students.each_with_index do |student, i|
  ParentStudentRelationship.create!(
    parent: parent_users[i % parent_users.length],
    student: student,
    relationship_type: [:mother, :father, :guardian].sample,
    contact_priority: 1,
    active: true
  )
end

# Add additional parents for some students (for realistic scenarios)
additional_relationships = [
  [0, 1], [2, 3], [4, 5], [6, 7], [8, 9]
]

additional_relationships.each do |student_idx, parent_idx|
  next if student_idx >= students.length || parent_idx >= parent_users.length
  
  ParentStudentRelationship.create!(
    parent: parent_users[parent_idx],
    student: students[student_idx],
    relationship_type: :guardian,
    contact_priority: 2,
    active: true
  )
end

# Create Attendance Records (for the past week)
puts "Creating attendance records..."
attendance_dates = (Date.current - 7.days..Date.current).to_a

students.each do |student|
  attendance_dates.each do |date|
    # Skip weekends
    next if date.saturday? || date.sunday?
    
    Attendance.create!(
      student: student,
      date: date,
      status: [:present, :present, :present, :present, :absent, :late].sample, # More likely to be present
      notes: rand(10) > 7 ? "Came in late today" : nil,
      staff: staff_users.sample
    )
  end
end

# Create Fee Records
puts "Creating fee records..."
students.each_with_index do |student, i|
  # Create monthly fees for each student
  3.times do |j|
    due_date = Date.current.beginning_of_month - j.months + rand(1..28).days
    Fee.create!(
      student: student,
      amount: rand(100..300),
      due_date: due_date,
      status: j == 0 ? [:pending, :overdue].sample : [:paid, :paid, :paid, :waived].sample,
      description: "Monthly tuition fee for #{due_date.strftime('%B %Y')}",
      receipt_number: "RCP#{rand(1000..9999)}"
    )
  end
end

# Create Events
puts "Creating events..."
event_titles = [
  "Parent-Teacher Conference",
  "School Picnic",
  "Art Exhibition",
  "Sports Day",
  "Science Fair",
  "Music Concert",
  "Field Trip to Zoo",
  "Reading Day",
  "Holiday Celebration",
  "Graduation Ceremony"
]

event_titles.each_with_index do |title, i|
  start_time = Time.current + i.weeks + rand(1..5).hours
  Event.create!(
    title: title,
    description: "Join us for #{title.downcase} at our school. All parents and children are welcome.",
    start_time: start_time,
    end_time: start_time + rand(2..4).hours,
    location: ["Main Hall", "Playground", "Classroom", "Garden"].sample,
    organizer: staff_users.sample
  )
end

# Create Curricula
puts "Creating curricula..."
curricula = []
curriculum_subjects = ["Math", "Reading", "Science", "Art", "Music", "Physical Education"]

classrooms.each_with_index do |classroom, i|
  curriculum_subjects.each_with_index do |subject, j|
    start_time = Time.current.beginning_of_month
    end_time = start_time + 3.months
    curricula << Curriculum.create!(
      title: "#{subject} Curriculum",
      description: "Curriculum for #{subject} in #{classroom.name}",
      start_time: start_time,
      end_time: end_time,
      subject: subject,
      classroom: classroom
    )
  end
end

# Create Resources
puts "Creating resources..."
resource_categories = ["Lesson Plan", "Worksheet", "Activity", "Assessment", "Reference"]

classrooms.each_with_index do |classroom, i|
  3.times do |j|
    resource = Resource.new(
      title: "Resource #{i+1}-#{j+1}",
      description: "Educational resource for #{classroom.name}",
      category: resource_categories.sample,
      subject: curriculum_subjects.sample,
      classroom: classroom,
      user: teacher_users.sample
    )
    # Skip validation for file attachment in seed data
    resource.save(validate: false)
  end
end

# Create Notifications
puts "Creating notifications..."
notification_types = [:general, :attendance, :fee, :event, :alert]

10.times do |i|
  Notification.create!(
    title: "Notification #{i+1}",
    message: "This is a sample notification message for testing purposes.",
    recipient_type: "User",
    recipient: User.all.sample,
    sender: staff_users.sample,
    sent_at: Time.current - rand(1..24).hours,
    notification_type: notification_types.sample
  )
end

# Create some attendance-related notifications
students.each_with_index do |student, i|
  next unless i % 4 == 0 # Every 4th student gets an attendance notification
  
  Notification.create!(
    title: "Attendance Alert",
    message: "#{student.full_name} was absent today.",
    recipient_type: "User",
    recipient: student.parent,
    sender: staff_users.sample,
    sent_at: Time.current - 1.hour,
    notification_type: :attendance
  )
end

puts "Database seeding completed successfully!"
puts ""
puts "Created:"
puts "  - 1 Admin user"
puts "  - 5 Staff users"
puts "  - 3 Teacher users" 
puts "  - 10 Parent users"
puts "  - 5 Classrooms"
puts "  - 20 Students"
puts "  - #{Attendance.count} Attendance records"
puts "  - #{Fee.count} Fee records"
puts "  - #{Event.count} Events"
puts "  - #{Curriculum.count} Curricula"
puts "  - #{Resource.count} Resources"
puts "  - #{Notification.count} Notifications"
puts "  - #{ParentStudentRelationship.count} Parent-Student relationships"