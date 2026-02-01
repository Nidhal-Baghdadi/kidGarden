class EventsDatatable < AjaxDatatablesRails::Base
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::FormHelper

  def view_columns
    @view_columns ||= {
      id:          { source: "Event.id", cond: :eq, searchable: true, orderable: true },
      title:       { source: "Event.title", cond: :like, searchable: true, orderable: true },
      start_time:  { source: "Event.start_time", cond: :like, searchable: true, orderable: true },
      end_time:    { source: "Event.end_time", cond: :like, searchable: true, orderable: true },
      location:    { source: "Event.location", cond: :like, searchable: true, orderable: true },
      organizer:   { source: "User.name", cond: :like, searchable: true, orderable: true },
      actions:     { source: "Event.id", searchable: false, orderable: false },
    }
  end

  def data
    records.map do |record|
      {
        id:          record.id,
        title:       record.title,
        start_time:  record.start_time.strftime("%B %d, %Y at %I:%M %p"),
        end_time:    record.end_time.strftime("%B %d, %Y at %I:%M %p"),
        location:    record.location,
        organizer:   record.organizer&.name || "N/A",
        actions:     link_to("View", record, class: "btn btn-outline") +
                     link_to("Edit", edit_event_path(record), class: "btn btn-outline") +
                     link_to("Delete", record, method: :delete, class: "btn btn-danger", data: { confirm: "Are you sure?" }),
        DT_RowId:    record.id,
      }
    end
  end

  private

  def get_raw_records
    return Event.none if params[:draw].blank?
    Event.left_joins(:organizer).distinct
  end

end
