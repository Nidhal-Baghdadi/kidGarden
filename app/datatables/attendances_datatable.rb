class AttendancesDatatable < AjaxDatatablesRails::Base
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::FormHelper

  def view_columns
    @view_columns ||= {
      id:        { source: "Attendance.id", cond: :eq, searchable: true, orderable: true },
      student:   { source: "Student.first_name", cond: :like, searchable: true, orderable: true },
      date:      { source: "Attendance.date", cond: :like, searchable: true, orderable: true },
      status:    { source: "Attendance.status", cond: :like, searchable: true, orderable: true },
      notes:     { source: "Attendance.notes", cond: :like, searchable: true, orderable: true },
      taken_by:  { source: "User.name", cond: :like, searchable: true, orderable: true },
      actions:   { source: "Attendance.id", searchable: false, orderable: false },
    }
  end

  def data
    records.map do |record|
      {
        id:        record.id,
        student:   record.student&.full_name,
        date:      record.date.strftime("%B %d, %Y"),
        status:    '<span class="status-badge status-' + record.status + '">' + record.status.humanize + '</span>',
        notes:     record.notes&.truncate(30) || "None",
        taken_by:  record.staff&.name || "System",
        actions:   link_to("View", record, class: "btn btn-outline") +
                   link_to("Edit", edit_attendance_path(record), class: "btn btn-outline") +
                   link_to("Delete", record, method: :delete, class: "btn btn-danger", data: { confirm: "Are you sure?" }),
        DT_RowId:  record.id,
      }
    end
  end

  private

  def get_raw_records
    return Attendance.none if params[:draw].blank?
    Attendance.left_joins(:student, :staff).distinct
  end
end
