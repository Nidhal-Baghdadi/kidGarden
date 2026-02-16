class OtpMailer < ApplicationMailer
  default from: "noreply@kidgarden.com"

  def login_otp_email(user, otp_code)
    @user = user
    @otp_code = otp_code
    @expires_in = 10.minutes.from_now.strftime("%H:%M")
    
    mail(
      to: @user.email,
      subject: "Your Login Verification Code - Kid Garden"
    )
  end

  def signup_verification_email(user)
    @user = user
    @verification_link = "#{ENV['APP_HOST'] || 'http://localhost:3000'}/users/verify/#{@user.verification_code}"
    
    mail(
      to: @user.email,
      subject: "Welcome to Kid Garden - Account Verification Required"
    )
  end
end