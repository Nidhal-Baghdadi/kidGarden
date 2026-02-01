class CalendarController < ApplicationController
  def index
    # Get curriculum and events for the current user's children or classroom
    if current_user.teacher?
      @classroom = current_user.classrooms_taught.first
      @curriculums = @classroom ? @classroom.curriculums : Curriculum.none
      @events = Event.all
    elsif current_user.parent?
      # Get curriculums for child's classroom
      @students = current_user.students_as_parent
      classroom_ids = @students.map(&:classroom_id).compact.uniq
      @curriculums = Curriculum.where(classroom_id: classroom_ids)
      @events = Event.all
    elsif current_user.admin?
      # Admin can see all
      @curriculums = Curriculum.all
      @events = Event.all
    else
      # Other users see no data
      @curriculums = Curriculum.none
      @events = Event.none
    end

    # Combine all events for calendar view
    @calendar_events = []
    @curriculums.each do |curriculum|
      @calendar_events << {
        title: curriculum.title,
        start: curriculum.start_time,
        end: curriculum.end_time,
        type: 'curriculum',
        description: curriculum.description,
        subject: curriculum.subject
      }
    end

    @events.each do |event|
      @calendar_events << {
        title: event.title,
        start: event.start_time,
        end: event.end_time,
        type: 'event',
        description: event.description
      }
    end
  end
end
