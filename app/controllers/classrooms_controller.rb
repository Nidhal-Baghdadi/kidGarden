class ClassroomsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_classroom, only: [:show, :edit, :update, :destroy]

  def index
    # match the same access logic you use elsewhere, but list only what user can see
    @classrooms =
      if current_user.admin?
        Classroom.includes(:teacher, :students).order(:name)
      elsif current_user.teacher?
        Classroom.where(teacher_id: current_user.id).includes(:teacher, :students).order(:name)
      elsif current_user.parent?
        Classroom
          .joins(:students)
          .where(students: { parent_id: current_user.id })
          .includes(:teacher, :students)
          .distinct
          .order(:name)
      else
        Classroom.none
      end
  end

  def show
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
      redirect_to @classroom, notice: "Classroom was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
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
    unless current_user.admin? || current_user.teacher?
      redirect_to root_path, alert: "You don't have permission to update this classroom."
      return
    end

    unless can_access_classroom?(@classroom)
      redirect_to root_path, alert: "You don't have permission to update this classroom."
      return
    end

    if @classroom.update(classroom_params)
      redirect_to @classroom, notice: "Classroom was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    unless current_user.admin?
      redirect_to root_path, alert: "You don't have permission to delete this classroom."
      return
    end

    @classroom.destroy
    redirect_to classrooms_path, notice: "Classroom was successfully deleted."
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
      (current_user.parent? && classroom.students.where(parent_id: current_user.id).exists?)
  end
end
