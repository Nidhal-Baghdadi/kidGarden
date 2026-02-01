class UsersDatatable < AjaxDatatablesRails::Base
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::FormHelper

  def view_columns
    @view_columns ||= {
      name:     { source: "User.name", cond: :like, searchable: true, orderable: true },
      email:    { source: "User.email", cond: :like, searchable: true, orderable: true },
      role:     { source: "User.role", cond: :like, searchable: true, orderable: true },
      status:   { source: "User.status", cond: :like, searchable: true, orderable: true },
      approved: { source: "User.approved", cond: :eq, searchable: true, orderable: true },
      actions:  { source: "User.id", searchable: false, orderable: false },
    }
  end

  def data
    records.map do |record|
      {
        name:     record.name,
        email:    record.email,
        role:     '<span class="status-badge status-' + record.role + '">' + record.role.humanize + '</span>',
        status:   '<span class="status-badge status-' + record.status + '">' + record.status.humanize + '</span>',
        approved: record.approved? ? 'Yes' : 'No',
        actions:  link_to('Show', record, class: 'btn btn-outline btn-sm') +
                  link_to('Edit', edit_user_path(record), class: 'btn btn-outline btn-sm') +
                  link_to('Delete', record, method: :delete, class: 'btn btn-danger btn-sm', data: { confirm: 'Are you sure?' }),
        DT_RowId: record.id,
      }
    end
  end

  private

  def get_raw_records
    return User.none if params[:draw].blank?
    User.all
  end
end
