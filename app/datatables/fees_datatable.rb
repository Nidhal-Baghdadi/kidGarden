class FeesDatatable < AjaxDatatablesRails::Base

  def view_columns
    # Declare strings in this format: ModelName.column_name
    # or in aliased formats for joins
    @view_columns ||= {
      id:             { source: "Fee.id", cond: :eq, searchable: true, orderable: true },
      student:        { source: "Student.first_name", cond: :like, searchable: true, orderable: true },
      amount:         { source: "Fee.amount", cond: :like, searchable: true, orderable: true },
      due_date:       { source: "Fee.due_date", cond: :like, searchable: true, orderable: true },
      status:         { source: "Fee.status", cond: :like, searchable: true, orderable: true },
      receipt_number: { source: "Fee.receipt_number", cond: :like, searchable: true, orderable: true },
      actions:        { source: "Fee.id", searchable: false, orderable: false },
    }
  end

  def data
    records.map do |record|
      {
        id:             record.id,
        student:        record.student&.full_name,
        amount:         record.amount,
        due_date:       record.due_date.strftime("%B %d, %Y"),
        status:         record.status.humanize,
        receipt_number: record.receipt_number || "N/A",
        actions:        "",
        DT_RowId:       record.id, # This will automagically set the id attribute on the tr element
      }
    end
  end

  private

  def get_raw_records
    # Insert a guard clause to prevent method from running before the view is initialized
    return Fee.none if params[:draw].blank?
    Fee.left_joins(:student).distinct
  end

end
