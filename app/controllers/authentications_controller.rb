class AuthenticationsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:request_otp, :verify_otp]

  def request_otp
    @email = params[:email]
    
    if @email.blank?
      render json: { error: 'Email is required' }, status: :unprocessable_entity
      return
    end

    user = User.find_by(email: @email.downcase)
    
    if user
      otp = user.generate_otp
      render json: { message: 'OTP sent successfully', email: @email }
    else
      render json: { error: 'User not found' }, status: :not_found
    end
  end

  def verify_otp
    @email = params[:email]
    @otp = params[:otp]
    
    if @email.blank? || @otp.blank?
      render json: { error: 'Email and OTP are required' }, status: :unprocessable_entity
      return
    end

    user = User.find_by(email: @email.downcase)
    
    if user&.verify_otp(@otp)
      # Sign in the user
      sign_in(user)
      render json: { message: 'OTP verified successfully', redirect_url: root_path }
    else
      render json: { error: 'Invalid or expired OTP' }, status: :unauthorized
    end
  end
end