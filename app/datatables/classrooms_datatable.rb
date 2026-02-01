class ClassroomsDatatable < AjaxDatatablesRails::Base
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::FormHelper

  def view_columns
    @view_columns ||= {
      id:           { source: "Classroom.id", cond: :eq, searchable: true, orderable: true },
      name:         { source: "Classroom.name", cond: :like, searchable: true, orderable: true },
      teacher:      { source: "User.name", cond: :like, searchable: true, orderable: true },
      capacity:     { source: "Classroom.capacity", cond: :like, searchable: true, orderable: true },
      student_count:{ source: "Classroom.id", searchable: false, orderable: true }, # Custom sorting based on student count
      actions:      { source: "Classroom.id", searchable: false, orderable: false },
    }
  end

  def data
    records.map do |record|
      {
        id:           record.id,
        name:         record.name,
        teacher:      record.teacher&.name || "Unassigned",
        capacity:     record.capacity,
        student_count:record.students.count,
        actions:      link_to("View", record, class: "btn btn-outline") +
                      link_to("Edit", edit_classroom_path(record), class: "btn btn-outline") +
                      link_to("Delete", record, method: :delete, class: "btn btn-danger", data: { confirm: "Are you sure?" }),
        DT_RowId:     record.id,
      }
    end
  end

  private

  def get_raw_records
    return Classroom.none if params[:draw].blank?
    Classroom.left_joins(:teacher, :students).distinct
  end
end
