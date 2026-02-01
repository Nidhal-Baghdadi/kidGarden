class StudentsDatatable < AjaxDatatablesRails::Base
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::FormHelper

  def view_columns
    @view_columns ||= {
      id:          { source: "Student.id", cond: :eq, searchable: true, orderable: true },
      student:     { source: "Student.first_name", cond: :like, searchable: true, orderable: true },
      classroom:   { source: "Classroom.name", cond: :like, searchable: true, orderable: true },
      status:      { source: "Student.status", cond: :like, searchable: true, orderable: true },
      gender:      { source: "Student.gender", cond: :like, searchable: true, orderable: true },
      enrollment:  { source: "Student.enrollment_date", cond: :like, searchable: true, orderable: true },
      actions:     { source: "Student.id", searchable: false, orderable: false },
    }
  end

  def data
    records.map do |record|
      {
        id:          record.id,
        student:     record.full_name,
        classroom:   record.classroom&.name || "Unassigned",
        status:      '<span class="status-badge status-' + record.status + '">' + record.status.humanize + '</span>',
        gender:      record.gender.humanize,
        enrollment:  record.enrollment_date&.strftime("%m/%d/%Y"),
        actions:     link_to("View", record, class: "btn btn-outline") +
                     link_to("Edit", edit_student_path(record), class: "btn btn-outline") +
                     link_to("Delete", record, method: :delete, class: "btn btn-danger", data: { confirm: "Are you sure?" }),
        DT_RowId:    record.id,
      }
    end
  end

  private

  def get_raw_records
    return Student.none if params[:draw].blank?
    Student.left_joins(:classroom).distinct
  end
end
