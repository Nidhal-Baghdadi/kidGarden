class FeesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_fee, only: [:show, :edit, :update, :destroy]

  def index
    @fees =
      if current_user.admin?
        Fee.includes(:student).order(due_date: :desc)
      elsif current_user.teacher?
        student_ids = Student.where(classroom_id: current_user.classrooms_taught.select(:id)).select(:id)
        Fee.where(student_id: student_ids).includes(:student).order(due_date: :desc)
      elsif current_user.parent?
        student_ids = Student.where(parent_id: current_user.id).select(:id)
        Fee.where(student_id: student_ids).includes(:student).order(due_date: :desc)
      else
        Fee.none
      end
  end

  def show
    unless can_access_fee?(@fee)
      redirect_to root_path, alert: "You don't have permission to view this fee."
      return
    end
  end

  def new
    @fee = Fee.new
  end

  def create
    @fee = Fee.new(fee_params)

    if @fee.save
      redirect_to @fee, notice: "Fee was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    unless current_user.admin? || current_user.teacher?
      redirect_to root_path, alert: "You don't have permission to edit this fee."
      return
    end

    unless can_access_fee?(@fee)
      redirect_to root_path, alert: "You don't have permission to edit this fee."
      return
    end
  end

  def update
    unless current_user.admin? || current_user.teacher?
      redirect_to root_path, alert: "You don't have permission to update this fee."
      return
    end

    unless can_access_fee?(@fee)
      redirect_to root_path, alert: "You don't have permission to update this fee."
      return
    end

    if @fee.update(fee_params)
      redirect_to @fee, notice: "Fee was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    unless current_user.admin?
      redirect_to root_path, alert: "You don't have permission to delete this fee."
      return
    end

    @fee.destroy
    redirect_to fees_path, notice: "Fee was successfully deleted."
  end

  private

  def set_fee
    @fee = Fee.find(params[:id])
  end

  def fee_params
    params.require(:fee).permit(:student_id, :amount, :due_date, :status, :description, :receipt_number)
  end

  def can_access_fee?(fee)
    return false unless fee.student

    current_user.admin? ||
      (current_user.teacher? && fee.student.classroom && fee.student.classroom.teacher == current_user) ||
      (current_user.parent? && fee.student.parent == current_user)
  end
end
