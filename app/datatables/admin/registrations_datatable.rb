class Admin::RegistrationsDatatable < AjaxDatatablesRails::Base
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::FormHelper

  def view_columns
    @view_columns ||= {
      name:             { source: "User.name", cond: :like, searchable: true, orderable: true },
      email:            { source: "User.email", cond: :like, searchable: true, orderable: true },
      role_request:     { source: "User.role_request", cond: :like, searchable: true, orderable: true },
      registration_date:{ source: "User.created_at", cond: :like, searchable: true, orderable: true },
      actions:          { source: "User.id", searchable: false, orderable: false }
    }
  end

  def data
    records.map do |record|
      {
        name:             record.name,
        email:            record.email,
        role_request:     case record.role_request
                          when 'teacher_request' then 'Teacher'
                          when 'parent_request' then 'Parent'
                          when 'staff_request' then 'Staff'
                          else 'N/A'
                          end,
        registration_date:record.created_at.strftime("%B %d, %Y at %I:%M %p"),
        actions:          link_to("View Details", admin_registration_path(record), class: "btn btn-outline") +
                          button_to("Approve", approve_admin_registration_path(record), method: :patch, class: "btn btn-primary", form: { style: "display:inline-block;" }, data: { confirm: "Are you sure you want to approve this registration?" }) +
                          link_to("Reject", reject_admin_registration_path(record), method: :patch, class: "btn btn-danger", data: { confirm: "Are you sure you want to reject this registration?" }),
        DT_RowId:         record.id
      }
    end
  end

  private

  def get_raw_records
    return User.none if params[:draw].blank?
    User.pending_approval
  end
end
