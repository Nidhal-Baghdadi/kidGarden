class PaymentsController < ApplicationController
  before_action :set_payment, only: [:show, :edit, :update, :destroy, :refund]

  def index
    respond_to do |format|
      format.html
      format.json { render json: PaymentsDatatable.new(params, view_context: view_context) }
    end
  end

  def show
    # Allow access based on role
    unless can_access_payment?(@payment)
      redirect_to root_path, alert: "You don't have permission to view this payment."
      return
    end
  end

  def new
    @payment = Payment.new
    @fees = Fee.where(status: ['pending', 'overdue'])
    
    # Filter fees based on user role
    if current_user.parent?
      student_ids = current_user.students_as_parent.ids
      @fees = @fees.where(student_id: student_ids)
    elsif current_user.teacher?
      classroom_ids = current_user.classrooms_taught.ids
      student_ids = Student.where(classroom_id: classroom_ids).ids
      @fees = @fees.where(student_id: student_ids)
    end
  end

  def create
    @payment = Payment.new(payment_params)
    @payment.created_by = current_user

    if @payment.save
      redirect_to @payment, notice: 'Payment was successfully recorded.'
    else
      @fees = Fee.all
      if current_user.parent?
        student_ids = current_user.students_as_parent.ids
        @fees = @fees.where(student_id: student_ids)
      elsif current_user.teacher?
        classroom_ids = current_user.classrooms_taught.ids
        student_ids = Student.where(classroom_id: classroom_ids).ids
        @fees = @fees.where(student_id: student_ids)
      end
      render :new
    end
  end

  def edit
    # Only teachers and admins can edit payments
    unless current_user.admin? || current_user.teacher?
      redirect_to root_path, alert: "You don't have permission to edit this payment."
      return
    end

    unless can_access_payment?(@payment)
      redirect_to root_path, alert: "You don't have permission to edit this payment."
      return
    end
  end

  def update
    # Only teachers and admins can update payments
    unless current_user.admin? || current_user.teacher?
      redirect_to root_path, alert: "You don't have permission to update this payment."
      return
    end

    unless can_access_payment?(@payment)
      redirect_to root_path, alert: "You don't have permission to update this payment."
      return
    end

    if @payment.update(payment_params)
      redirect_to @payment, notice: 'Payment was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    # Only admins can delete payments
    unless current_user.admin?
      redirect_to root_path, alert: "You don't have permission to delete this payment."
      return
    end

    @payment.destroy
    redirect_to payments_url, notice: 'Payment was successfully deleted.'
  end

  def refund
    # Only admins and teachers can refund payments
    unless current_user.admin? || current_user.teacher?
      redirect_to root_path, alert: "You don't have permission to refund this payment."
      return
    end

    unless can_access_payment?(@payment)
      redirect_to root_path, alert: "You don't have permission to refund this payment."
      return
    end

    if @payment.refund!
      redirect_to @payment, notice: 'Payment was successfully refunded.'
    else
      redirect_to @payment, alert: 'Failed to refund payment.'
    end
  end

  private

  def set_payment
    @payment = Payment.find(params[:id])
  end

  def payment_params
    params.require(:payment).permit(:fee_id, :student_id, :amount, :payment_method, :status, :notes, :reference_number, :payment_date, :transaction_id, :payment_metadata)
  end

  def can_access_payment?(payment)
    return false unless payment.fee&.student

    current_user.admin? ||
    (current_user.teacher? && payment.fee.student.classroom && payment.fee.student.classroom.teacher == current_user) ||
    (current_user.parent? && payment.fee.student.parent == current_user)
  end
end