class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :students_as_parent, foreign_key: 'parent_id', class_name: 'Student', dependent: :nullify
  has_many :classrooms_taught, foreign_key: 'teacher_id', class_name: 'Classroom', dependent: :nullify
  has_many :attendances_taken, foreign_key: 'staff_id', class_name: 'Attendance', dependent: :nullify
  has_many :events_organized, foreign_key: 'organizer_id', class_name: 'Event', dependent: :nullify
  has_many :sent_notifications, foreign_key: 'sender_id', class_name: 'Notification', dependent: :nullify
  has_many :received_notifications, foreign_key: 'recipient_id', class_name: 'Notification', dependent: :nullify
  has_many :sent_messages, foreign_key: 'sender_id', class_name: 'Message', dependent: :nullify
  has_many :received_messages, foreign_key: 'recipient_id', class_name: 'Message', dependent: :nullify
  has_many :conversation_participations, foreign_key: 'user_id', class_name: 'ConversationParticipant', dependent: :nullify
  has_many :conversations, through: :conversation_participations
  has_many :message_read_receipts, foreign_key: 'user_id', class_name: 'MessageReadReceipt', dependent: :nullify

  enum :role, { admin: 0, teacher: 1, parent: 2, staff: 3 }
  enum :status, { active: 0, inactive: 1, suspended: 2 }
  enum :role_request, { teacher_request: 0, parent_request: 1, staff_request: 2 }

  validates :email, presence: true, uniqueness: true
  validates :name, presence: true

  before_create :set_verification_code

  def admin?
    role == 'admin'
  end

  def teacher?
    role == 'teacher'
  end

  def parent?
    role == 'parent'
  end

  def staff?
    role == 'staff'
  end

  def unapproved?
    !approved
  end

  def pending_approval?
    !approved && verification_code.present?
  end

  def approve!
    update(approved: true, approved_at: Time.current)
  end

  scope :pending_approval, -> { where(approved: false).where.not(role_request: nil) }

  def full_name
    name
  end

  # OTP Methods
  def generate_otp
    # Generate a 6-digit numeric OTP
    otp = rand(100000..999999).to_s
    self.otp_secret = otp
    self.otp_expires_at = 10.minutes.from_now
    self.otp_attempts_count = 0
    save!

    # Send the OTP email
    OtpMailer.login_otp_email(self, otp).deliver_later

    otp
  end

  def verify_otp(input_otp)
    # Check if OTP is expired
    return false if otp_expires_at.nil? || otp_expires_at < Time.current

    # Check if attempts exceeded
    return false if otp_attempts_count >= 3

    # Verify OTP
    if otp_secret == input_otp
      # Reset OTP fields after successful verification
      self.otp_secret = nil
      self.otp_expires_at = nil
      save!
      true
    else
      # Increment attempt count
      increment!(:otp_attempts_count)
      false
    end
  end

  def otp_expired?
    otp_expires_at.present? && otp_expires_at < Time.current
  end

  def send_welcome_email
    OtpMailer.signup_verification_email(self).deliver_later
  end

  private

  def set_verification_code
    self.verification_code = generate_verification_code
  end

  def generate_verification_code
    loop do
      code = SecureRandom.hex(5) # 10 character code
      break code unless User.find_by(verification_code: code)
    end
  end
end
