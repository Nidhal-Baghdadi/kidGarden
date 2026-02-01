class ClassroomsController < ApplicationController
  before_action :set_classroom, only: [:show, :edit, :update, :destroy]

  def index
    respond_to do |format|
      format.html
      format.json { render json: ClassroomsDatatable.new(params, view_context: view_context) }
    end
  end

  def show
    # Allow access based on role
    unless can_access_classroom?(@classroom)
      redirect_to root_path, alert: "You don't have permission to view this classroom."
      return
    end
  end

  def new
    @classroom = Classroom.new
  end

  def create
    @classroom = Classroom.new(classroom_params)

    if @classroom.save
      redirect_to @classroom, notice: 'Classroom was successfully created.'
    else
      render :new
    end
  end

  def edit
    # Only teachers and admins can edit classrooms
    unless current_user.admin? || current_user.teacher?
      redirect_to root_path, alert: "You don't have permission to edit this classroom."
      return
    end

    unless can_access_classroom?(@classroom)
      redirect_to root_path, alert: "You don't have permission to edit this classroom."
      return
    end
  end

  def update
    # Only teachers and admins can update classrooms
    unless current_user.admin? || current_user.teacher?
      redirect_to root_path, alert: "You don't have permission to update this classroom."
      return
    end

    unless can_access_classroom?(@classroom)
      redirect_to root_path, alert: "You don't have permission to update this classroom."
      return
    end

    if @classroom.update(classroom_params)
      redirect_to @classroom, notice: 'Classroom was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    # Only admins can delete classrooms
    unless current_user.admin?
      redirect_to root_path, alert: "You don't have permission to delete this classroom."
      return
    end

    @classroom.destroy
    redirect_to classrooms_url, notice: 'Classroom was successfully deleted.'
  end

  private

  def set_classroom
    @classroom = Classroom.find(params[:id])
  end

  def classroom_params
    params.require(:classroom).permit(:name, :capacity, :description, :teacher_id, :schedule)
  end

  def can_access_classroom?(classroom)
    current_user.admin? ||
    (current_user.teacher? && classroom.teacher == current_user) ||
    (current_user.parent? && classroom.students.joins(:parent).where(users: { id: current_user.id }).exists?)
  end
end
