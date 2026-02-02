class InvoicesController < ApplicationController
  before_action :set_invoice, only: [:show, :edit, :update, :destroy, :download_pdf]
  before_action :set_associations, only: [:new, :edit]

  def index
    @invoices = Invoice.includes(:student, :parent).all

    # Apply filters if present
    if params[:student_id].present?
      @invoices = @invoices.where(student_id: params[:student_id])
    end

    if params[:status].present?
      @invoices = @invoices.where(status: params[:status])
    end

    if params[:month].present? && params[:year].present?
      @invoices = @invoices.where(month: params[:month], year: params[:year])
    end

    @invoices = @invoices.order(created_at: :desc)
  end

  def show
  end

  def new
    @invoice = Invoice.new
    @invoice.invoice_items.build # Initialize one empty item

    # Pre-populate invoice items if coming from fees
    if params[:fee_ids].present?
      fee_ids = params[:fee_ids].split(',').map(&:to_i)
      @fees = Fee.where(id: fee_ids)

      @fees.each do |fee|
        @invoice.invoice_items.build(fee: fee, amount: fee.amount, description: fee.description)
      end
    end
  end

  def create
    @invoice = Invoice.new(invoice_params)
    @invoice.created_by = current_user if current_user

    if @invoice.save
      redirect_to @invoice, notice: 'Invoice was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @invoice.update(invoice_params)
      redirect_to @invoice, notice: 'Invoice was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @invoice.destroy
    redirect_to invoices_url, notice: 'Invoice was successfully deleted.'
  end

  def download_pdf
    pdf_generator = InvoicePdfGenerator.new(@invoice)
    pdf_content = pdf_generator.generate

    send_data pdf_content,
              filename: "invoice_#{@invoice.invoice_number}.pdf",
              type: 'application/pdf',
              disposition: 'inline'
  end

  private

  def set_invoice
    @invoice = Invoice.find(params[:id])
  end

  def set_associations
    @students = Student.all
    @parents = User.where(role: :parent)
  end

  def invoice_params
    params.require(:invoice).permit(:student_id, :parent_id, :month, :year, :due_date, :status, :notes,
                                   invoice_items_attributes: [:id, :fee_id, :amount, :description, :_destroy])
  end
end