class StudentsDatatable < AjaxDatatablesRails::Base
  include ActionView::Helpers::UrlHelper
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::TagHelper

  def view_columns
    @view_columns ||= {
      id:         { source: "Student.id", orderable: true, searchable: false },
      student:    { source: "Student.first_name", cond: :like, searchable: true, orderable: true },
      classroom:  { source: "Classroom.name", cond: :like, searchable: true, orderable: true },
      status:     { source: "Student.status", cond: :like, searchable: true, orderable: true },
      gender:     { source: "Student.gender", cond: :like, searchable: true, orderable: true },
      enrollment: { source: "Student.enrollment_date", searchable: false, orderable: true },
      actions:    { source: "Student.id", searchable: false, orderable: false }
    }
  end

  def data
    records.map do |record|
      {
        id: record.id,
        student: record.full_name,
        classroom: record.classroom&.name || "Unassigned",
        status: status_badge(record),
        gender: record.gender&.humanize || "—",
        enrollment: record.enrollment_date&.strftime("%m/%d/%Y") || "—",
        actions: action_buttons(record),
        DT_RowId: "student_#{record.id}"
      }
    end
  end

  private

  def get_raw_records
    user = options[:current_user]
    return Student.none unless user

    base = Student
      .left_joins(:classroom)
      .includes(:classroom, :parent) # avoids N+1 when accessing classroom/parent
      .distinct

    if user.admin?
      base
    elsif user.teacher?
      base.where(classroom_id: user.classrooms_taught.select(:id))
    elsif user.parent?
      base.where(parent_id: user.id)
    else
      Student.none
    end
  end

  def status_badge(record)
    klass = "status-badge status-#{record.status}"
    content_tag(:span, record.status.humanize, class: klass)
  end

  def action_buttons(record)
    safe_join(
      [
        link_to("View", record, class: "btn btn-sm"),
        link_to("Edit", edit_student_path(record), class: "btn btn-sm"),
        link_to("Delete", record, method: :delete, data: { confirm: "Are you sure?" }, class: "btn btn-ghost btn-sm")
      ],
      " "
    )
  end
end
