class ResourcesDatatable < AjaxDatatablesRails::Base

  def view_columns
    # Declare strings in this format: ModelName.column_name
    # or in aliased formats for joins
    @view_columns ||= {
      title:       { source: "Resource.title", cond: :like, searchable: true, orderable: true },
      category:    { source: "Resource.category", cond: :like, searchable: true, orderable: true },
      subject:     { source: "Resource.subject", cond: :like, searchable: true, orderable: true },
      classroom:   { source: "Classroom.name", cond: :like, searchable: true, orderable: true },
      uploaded_by: { source: "User.name", cond: :like, searchable: true, orderable: true },
      actions:     { source: "Resource.id", searchable: false, orderable: false },
    }
  end

  def data
    records.map do |record|
      {
        title:       record.title,
        category:    record.category.humanize,
        subject:     record.subject,
        classroom:   record.classroom&.name || "All",
        uploaded_by: record.user&.name || "System",
        actions:     "",
        DT_RowId:    record.id, # This will automagically set the id attribute on the tr element
      }
    end
  end

  private

  def get_raw_records
    # Insert a guard clause to prevent method from running before the view is initialized
    return Resource.none if params[:draw].blank?
    Resource.left_joins(:classroom, :user).distinct
  end

end
