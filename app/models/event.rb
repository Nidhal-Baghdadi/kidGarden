class Event < ApplicationRecord
  belongs_to :organizer, class_name: 'User', optional: true

  validates :title, :start_time, :end_time, presence: true
  validate :end_time_after_start_time

  private

  def end_time_after_start_time
    return unless start_time.present? && end_time.present?

    if end_time <= start_time
      errors.add(:end_time, 'must be after start time')
    end
  end
end
