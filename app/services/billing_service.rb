class BillingService
  def initialize(school_id = nil)
    @school_id = school_id
  end

  # Generate monthly invoices for all students
  def generate_monthly_invoices(month = Date.current.month, year = Date.current.year)
    # Find all active students
    students = Student.includes(:parent, :classroom).where(status: :enrolled)
    
    # Filter by school if provided
    students = students.joins(:classroom).where(classrooms: { school_id: @school_id }) if @school_id

    invoices = []
    students.each do |student|
      invoice = create_invoice_for_student(student, month, year)
      invoices << invoice if invoice
    end

    invoices
  end

  # Create an invoice for a specific student
  def create_invoice_for_student(student, month, year)
    # Determine fees for this student for the given month
    monthly_fees = determine_monthly_fees(student, month, year)

    return nil if monthly_fees.blank?

    # Calculate total amount with applicable discounts
    total_amount = calculate_total_with_discounts(student, monthly_fees)

    # Create invoice record
    invoice = Invoice.create!(
      student: student,
      parent: student.parent,
      month: month,
      year: year,
      total_amount: total_amount,
      due_date: calculate_due_date(month, year),
      status: 'pending',
      created_by: find_billing_user
    )

    # Associate fees with the invoice
    monthly_fees.each do |fee|
      InvoiceItem.create!(
        invoice: invoice,
        fee: fee,
        amount: fee.total_amount || fee.amount
      )
    end

    invoice
  end

  # Send payment reminders
  def send_payment_reminders(days_before_due = 3)
    upcoming_invoices = Invoice.where(
      status: 'pending',
      due_date: (Date.current)..(Date.current + days_before_due.days)
    )

    upcoming_invoices.each do |invoice|
      send_reminder_email(invoice)
    end

    upcoming_invoices.size
  end

  # Process automatic payments (if payment methods are stored)
  def process_automatic_payments
    pending_invoices = Invoice.where(status: 'pending', due_date: ..Date.current)

    processed_count = 0
    pending_invoices.each do |invoice|
      if invoice.parent&.has_automatic_payment_setup?
        payment = process_automatic_payment(invoice)
        processed_count += 1 if payment
      end
    end

    processed_count
  end

  private

  def determine_monthly_fees(student, month, year)
    # Get all fees for this student that apply to the given month
    # This would typically include:
    # - Monthly tuition
    # - Canteen fees
    # - Transportation fees
    # - Extracurricular activity fees
    # - Other recurring fees

    start_date = Date.new(year, month, 1)
    end_date = start_date.end_of_month

    student.fees.where(
      due_date: start_date..end_date
    ).where.not(status: :paid)
  end

  def calculate_total_with_discounts(student, fees)
    total = fees.sum(&:total_amount) # Use calculated total with discounts
    total = fees.sum(&:amount) if total.zero? # Fallback to original amount if no discounts calculated

    # Apply any additional family-wide discounts
    apply_family_discounts(student, total)
  end

  def apply_family_discounts(student, total)
    # Find siblings in the same family
    family_students = Student.joins(:parent_student_relationships)
                            .where(parent_student_relationships: { parent_id: student.parent_id })
                            .distinct

    if family_students.count > 1
      # Look for sibling discounts
      sibling_discounts = Discount.where(
        discount_type: 'sibling_discount',
        applicable_to: ['tuition', 'all_fees'],
        start_date: ..Date.current,
        end_date: Date.current..,
        active: true
      )

      discount_amount = 0
      sibling_discounts.each do |discount|
        if discount.discount_type_fixed_amount?
          discount_amount += [discount.value, total].min
        elsif discount.discount_type_percentage?
          discount_amount += total * (discount.value / 100.0)
        end
      end

      total -= discount_amount
    end

    [total, 0].max # Ensure total doesn't go negative
  end

  def calculate_due_date(month, year)
    # Default: 5th of the following month
    due_date = Date.new(year, month, 1).next_month + 4.days
    # Adjust if due date falls on weekend
    due_date += 1.day while due_date.saturday? || due_date.sunday?
    due_date
  end

  def find_billing_user
    # Find a system user responsible for billing
    User.find_by(email: 'billing@kidgarden.system') || User.first
  end

  def send_reminder_email(invoice)
    # In a real implementation, this would send an email
    # For now, we'll just log it
    Rails.logger.info "Payment reminder sent for invoice ##{invoice.id} to #{invoice.parent&.name}"
  end

  def process_automatic_payment(invoice)
    # In a real implementation, this would process actual payment
    # For now, we'll just simulate it
    return nil unless invoice.parent&.has_automatic_payment_setup?

    # Create a payment record
    payment = Payment.create!(
      fee: invoice.invoice_items.first&.fee, # Link to first fee in invoice
      student: invoice.student,
      amount: invoice.total_amount,
      payment_method: 'automatic',
      status: 'completed',
      payment_date: Date.current,
      reference_number: "AUTO_#{invoice.id}_#{Time.current.to_i}",
      created_by: find_billing_user
    )

    # Update invoice status
    invoice.update!(status: 'paid')

    payment
  end
end