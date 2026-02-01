class Classroom < ApplicationRecord
  belongs_to :teacher, class_name: 'User', optional: true
  has_many :students, dependent: :nullify
  has_many :attendances, through: :students

  validates :name, presence: true, uniqueness: { scope: :teacher_id }
  validates :capacity, presence: true, numericality: { greater_than: 0 }
end
