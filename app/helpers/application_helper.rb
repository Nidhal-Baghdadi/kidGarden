module ApplicationHelper
  def status_badge(status, status_type = nil)
    css_class = case status&.to_s
                when 'active', 'present', 'paid', 'enrolled'
                  'status-badge professional-badge status-active professional-badge-active'
                when 'inactive', 'absent', 'overdue', 'withdrawn'
                  'status-badge professional-badge status-inactive professional-badge-inactive'
                else
                  'status-badge professional-badge status-default'
                end

    content_tag :span, status&.humanize, class: css_class
  end

  def professional_button(text, path, options = {})
    options[:class] = "#{options[:class]} btn professional-btn #{options[:variant] ? "professional-btn-#{options[:variant]}" : "professional-btn-primary"}"
    link_to text, path, options
  end

  def format_currency(amount)
    number_to_currency(amount, unit: "$", precision: 2) if amount
  end

  def format_date(date)
    date&.strftime("%B %d, %Y") if date
  end

  def format_datetime(datetime)
    datetime&.strftime("%B %d, %Y at %I:%M %p") if datetime
  end

  def nav_link_class(path, controller_name, controller_match = nil)
    active = if controller_match
      controller_name == controller_match
    else
      current_page?(path)
    end

    "nav__link #{active ? 'is-active' : ''}"
  end

end