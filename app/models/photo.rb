class Photo < ApplicationRecord
  belongs_to :student
  belongs_to :uploaded_by, class_name: 'User'
  belongs_to :classroom, optional: true
  
  has_one_attached :image

  validates :title, presence: true
  validates :description, length: { maximum: 500 }
  validates :image, presence: true
  
  scope :recent, -> { order(created_at: :desc) }
  scope :by_date, ->(date) { where(created_at: date.beginning_of_day..date.end_of_day) }
  scope :by_classroom, ->(classroom) { where(classroom: classroom) }
  scope :by_student, ->(student) { where(student: student) }
  
  def image_url
    image.attached? ? Rails.application.routes.url_helpers.rails_blob_path(image, only_path: true) : nil
  end

  def thumbnail_url
    return nil unless image.attached?
    begin
      Rails.application.routes.url_helpers.rails_representation_path(image.variant(resize_to_limit: [150, 150]), only_path: true)
    rescue => e
      # If image processing fails (e.g., missing libvips), return the original image URL
      Rails.application.routes.url_helpers.rails_blob_path(image, only_path: true)
    end
  end

  def medium_image_url
    return nil unless image.attached?
    begin
      Rails.application.routes.url_helpers.rails_representation_path(image.variant(resize_to_limit: [400, 400]), only_path: true)
    rescue => e
      # If image processing fails (e.g., missing libvips), return the original image URL
      Rails.application.routes.url_helpers.rails_blob_path(image, only_path: true)
    end
  end
  
  def accessible_by?(user)
    case user.role
    when 'admin'
      true
    when 'teacher'
      # Teachers can see photos of students in their classrooms
      classroom&.teacher == user
    when 'parent'
      # Parents can see photos of their own children
      student.parent_id == user.id
    else
      false
    end
  end
  
  def self.accessible_by(user)
    case user.role
    when 'admin'
      all
    when 'teacher'
      # Teachers can see photos of students in their classrooms
      joins(:student).where(students: { classroom_id: user.classrooms_taught.ids })
    when 'parent'
      # Parents can see photos of their own children
      where(student_id: user.students_as_parent.ids)
    else
      none
    end
  end
end