class FeesController < ApplicationController
  before_action :set_fee, only: [:show, :edit, :update, :destroy]

  def index
    respond_to do |format|
      format.html
      format.json { render json: FeesDatatable.new(params, view_context: view_context) }
    end
  end

  def show
    # Allow access based on role
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
      redirect_to @fee, notice: 'Fee was successfully created.'
    else
      render :new
    end
  end

  def edit
    # Only teachers and admins can edit fees
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
    # Only teachers and admins can update fees
    unless current_user.admin? || current_user.teacher?
      redirect_to root_path, alert: "You don't have permission to update this fee."
      return
    end

    unless can_access_fee?(@fee)
      redirect_to root_path, alert: "You don't have permission to update this fee."
      return
    end

    if @fee.update(fee_params)
      redirect_to @fee, notice: 'Fee was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    # Only admins can delete fees
    unless current_user.admin?
      redirect_to root_path, alert: "You don't have permission to delete this fee."
      return
    end

    @fee.destroy
    redirect_to fees_url, notice: 'Fee was successfully deleted.'
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
