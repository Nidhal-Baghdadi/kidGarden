require 'prawn'
require 'prawn/table'

class InvoicePdfGenerator
  def initialize(invoice)
    @invoice = invoice
  end

  def generate
    Prawn::Document.new(page_size: 'A4') do |pdf|
      # Create the invoice
      generate_invoice_content(pdf)

      # Return the generated PDF
      pdf.render
    end
  end

  private

  def generate_invoice_content(pdf)
    # Header with school information
    logo_path = Rails.root.join("app", "assets", "images", "logo.png")
    if File.exist?(logo_path)
      pdf.image(logo_path, width: 80, height: 80)
    end

    pdf.move_down 10
    pdf.text "Kid Garden School", size: 20, style: :bold, align: :center
    pdf.text "123 Education Street, Tunis", size: 12, align: :center
    pdf.text "Phone: +216 12 345 678 | Email: info@kidgarden.tn", size: 10, align: :center

    # Invoice title
    pdf.move_down 20
    pdf.text "INVOICE", size: 24, style: :bold, align: :right
    pdf.stroke_horizontal_rule
    pdf.move_down 10

    # Invoice details
    invoice_details_data = [
      ["Invoice Number:", @invoice.invoice_number || "INV-#{@invoice.id}"],
      ["Issue Date:", @invoice.issue_date.strftime("%B %d, %Y")],
      ["Due Date:", @invoice.due_date.strftime("%B %d, %Y")],
      ["Student:", "#{@invoice.student.first_name} #{@invoice.student.last_name}"],
      ["Parent/Guardian:", "#{@invoice.parent.name}"]
    ]

    pdf.table(invoice_details_data, column_widths: [150, 200]) do |table|
      table.cells.padding = 5
      table.cells.borders = []
      table.columns(0).font_style = :bold
    end

    pdf.move_down 20

    # Invoice items header
    pdf.text "Description", size: 12, style: :bold
    pdf.move_down 5
    pdf.stroke_horizontal_rule

    # Invoice items
    if @invoice.invoice_items.any?
      table_data = [["Description", "Amount"]]
      @invoice.invoice_items.each do |item|
        table_data << [item.description || "Item ##{item.id}", "$#{item.amount.to_f.round(2)}"]
      end

      # Add total
      table_data << ["TOTAL", "$#{@invoice.total_amount.to_f.round(2)}"]

      pdf.table(table_data, header: true, column_widths: [300, 150]) do |table|
        table.cells.padding = 8
        table.cells.border_color = "DDDDDD"
        table.rows(-1).font_style = :bold if table.row_count > 1
        table.row(0).background_color = "EEEEEE"
        table.row(-1).background_color = "EEEEEE" if table.row_count > 1
      end
    else
      pdf.text "No items listed for this invoice."
    end

    pdf.move_down 20

    # Payment information
    pdf.text "Payment Terms:", style: :bold
    pdf.text "Please make payment by the due date. Late payments may incur additional fees."
    pdf.move_down 10

    # Thank you message
    pdf.text "Thank you for choosing Kid Garden School!", style: :italic
  end
end