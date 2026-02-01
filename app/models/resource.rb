class Resource < ApplicationRecord
  belongs_to :classroom, optional: true
  belongs_to :user, optional: true

  has_one_attached :file

  validates :title, :category, presence: true
  validate :file_attached

  def file_attached
    errors.add(:file, "must be attached") unless file.attached?
  end
end
