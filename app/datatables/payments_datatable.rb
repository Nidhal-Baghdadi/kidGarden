class PaymentsDatatable < AjaxDatatablesRails::Base
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::FormHelper

  def view_columns
    @view_columns ||= {
      id:            { source: "Payment.id", cond: :eq, searchable: true, orderable: true },
      student:       { source: "Student.first_name", cond: :like, searchable: true, orderable: true },
      fee:           { source: "Fee.description", cond: :like, searchable: true, orderable: true },
      amount:        { source: "Payment.amount", cond: :like, searchable: true, orderable: true },
      method:        { source: "Payment.payment_method", cond: :like, searchable: true, orderable: true },
      date:          { source: "Payment.payment_date", cond: :like, searchable: true, orderable: true },
      status:        { source: "Payment.status", cond: :like, searchable: true, orderable: true },
      actions:       { source: "Payment.id", searchable: false, orderable: false },
    }
  end

  def data
    records.map do |record|
      {
        id:            record.id,
        student:       record.fee&.student&.full_name,
        fee:           record.fee&.description || "Fee ##{record.fee_id}",
        amount:        "$%.2f" % record.amount,
        method:        record.payment_method_label,
        date:          record.payment_date.strftime("%B %d, %Y"),
        status:        '<span class="status-badge status-' + record.status + '">' + record.status_label + '</span>',
        actions:       link_to("View", record, class: "btn btn-outline") +
                       link_to("Edit", edit_payment_path(record), class: "btn btn-outline") +
                       (record.status_completed? ? link_to("Refund", refund_payment_path(record), method: :patch, class: "btn btn-danger", confirm: "Are you sure you want to refund this payment?") : ""),
        DT_RowId:      record.id,
      }
    end
  end

  private

  def get_raw_records
    return Payment.none if params[:draw].blank?
    Payment.left_joins(fee: :student).distinct
  end
end
