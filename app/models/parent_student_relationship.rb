class ParentStudentRelationship < ApplicationRecord
  belongs_to :parent, class_name: 'User'
  belongs_to :student

  enum :relationship_type, { mother: 0, father: 1, guardian: 2, emergency_contact: 3 }

  validates :parent_id, :student_id, presence: true
  validates :parent_id, uniqueness: { scope: :student_id }
end
