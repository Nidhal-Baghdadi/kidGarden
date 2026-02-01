class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event, only: [:show, :edit, :update, :destroy]

  def index
    @events =
      if current_user.admin? || current_user.staff?
        Event.includes(:organizer).order(start_time: :desc)
      elsif current_user.teacher?
        # If teachers should only see their events, uncomment the next line and remove the "all events" line
        # Event.where(organizer_id: current_user.id).includes(:organizer).order(start_time: :desc)

        # Teachers can see all events (common for school calendar)
        Event.includes(:organizer).order(start_time: :desc)
      elsif current_user.parent?
        # Parents can see school-wide events
        Event.includes(:organizer).order(start_time: :desc)
      else
        Event.none
      end
  end

  def show
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)

    if @event.save
      redirect_to @event, notice: "Event was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @event.update(event_params)
      redirect_to @event, notice: "Event was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @event.destroy
    redirect_to events_path, notice: "Event was successfully deleted."
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:title, :description, :start_time, :end_time, :location, :organizer_id)
  end
end
