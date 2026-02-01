# Decorator for Student model to handle view-specific formatting
class StudentDecorator
  def initialize(student)
    @student = student
  end

  def full_name
    "#{@student.first_name} #{@student.last_name}"
  end

  def age
    return nil unless @student.date_of_birth
    
    now = Date.current
    age = now.year - @student.date_of_birth.year
    age -= 1 if @student.date_of_birth.month > now.month || 
              (@student.date_of_birth.month == now.month && @student.date_of_birth.day > now.day)
    age
  end

  def display_status
    status_text = @student.status.humanize
    case @student.status
    when 'enrolled'
      "<span class='status-badge status-active'>#{status_text}</span>".html_safe
    when 'withdrawn'
      "<span class='status-badge status-inactive'>#{status_text}</span>".html_safe
    else
      "<span class='status-badge'>#{status_text}</span>".html_safe
    end
  end

  def emergency_contact_info
    return "None provided" unless @student.emergency_contact_name
    "#{@student.emergency_contact_name} (#{@student.emergency_contact_phone})"
  end

  def method_missing(method_name, *args, &block)
    if @student.respond_to?(method_name)
      @student.send(method_name, *args, &block)
    else
      super
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    @student.respond_to?(method_name, include_private) || super
  end
end