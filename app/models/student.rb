class Student < ApplicationRecord
  belongs_to :parent, class_name: 'User', optional: true
  belongs_to :classroom, optional: true
  has_many :attendances, dependent: :destroy
  has_many :fees, dependent: :destroy
  has_many :parent_student_relationships, dependent: :destroy
  has_many :all_parents, -> { distinct }, through: :parent_student_relationships, source: :parent

  enum :status, { enrolled: 0, withdrawn: 1, suspended: 2, graduated: 3 }
  enum :gender, { male: 0, female: 1, other: 2 }

  validates :first_name, :last_name, presence: true
  validates :date_of_birth, presence: true

  def full_name
    "#{first_name} #{last_name}"
  end
end
