class RegistrationsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :check_approval_status

  def new_teacher
    @user = User.new
  end

  def new_parent
    @user = User.new
  end

  def create_teacher
    @user = User.new(user_params)
    @user.role_request = 'teacher_request'

    if @user.save
      # Send notification to admin for approval
      # In a real app, you would send an email here
      redirect_to root_path, notice: 'Your registration has been submitted for approval. You will receive an email when approved.'
    else
      render :new_teacher
    end
  end

  def create_parent
    @user = User.new(user_params)
    @user.role_request = 'parent_request'

    if @user.save
      # Send notification to admin for approval
      # In a real app, you would send an email here
      redirect_to root_path, notice: 'Your registration has been submitted for approval. You will receive an email when approved.'
    else
      render :new_parent
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end