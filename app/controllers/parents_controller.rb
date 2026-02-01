class ParentsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin_or_teacher_permissions

  def index
    if current_user.admin?
      @parents = User.where(role: :parent).includes(:students_as_parent)
    elsif current_user.teacher?
      # Get parents of students in the teacher's classrooms
      classroom_ids = current_user.classrooms_taught.ids
      student_ids = Student.where(classroom_id: classroom_ids).ids
      @parents = User.joins(:students_as_parent)
                     .where(role: :parent, students_as_parent: { id: student_ids })
                     .distinct
                     .includes(:students_as_parent)
    end
  end

  def show
    @parent = User.includes(:students_as_parent, :classrooms_taught).find(params[:id])
    
    # Verify user has permission to view this parent
    unless can_view_parent?(@parent)
      redirect_to parents_path, alert: "You don't have permission to view this parent."
      return
    end
  end

  def new
    @parent = User.new
  end

  def create
    @parent = User.new(parent_params)
    @parent.role = :parent
    @parent.password = params[:user][:password]
    @parent.password_confirmation = params[:user][:password_confirmation]

    if @parent.save
      redirect_to @parent, notice: 'Parent account was successfully created.'
    else
      render :new
    end
  end

  def edit
    @parent = User.find(params[:id])
    
    # Verify user has permission to edit this parent
    unless can_edit_parent?(@parent)
      redirect_to parents_path, alert: "You don't have permission to edit this parent."
      return
    end
  end

  def update
    @parent = User.find(params[:id])
    
    # Verify user has permission to update this parent
    unless can_edit_parent?(@parent)
      redirect_to parents_path, alert: "You don't have permission to update this parent."
      return
    end

    if @parent.update(parent_params)
      redirect_to @parent, notice: 'Parent account was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @parent = User.find(params[:id])
    
    # Only admins can delete parents
    unless current_user.admin?
      redirect_to parents_path, alert: "You don't have permission to delete parents."
      return
    end

    @parent.destroy
    redirect_to parents_path, notice: 'Parent account was successfully deleted.'
  end

  private

  def parent_params
    params.require(:user).permit(:name, :email, :phone, :address, :date_of_birth, :avatar)
  end

  def check_admin_or_teacher_permissions
    unless current_user.admin? || current_user.teacher?
      redirect_to root_path, alert: "You don't have permission to access this section."
    end
  end

  def can_view_parent?(parent)
    return true if current_user.admin?
    return false unless current_user.teacher?

    # Teachers can view parents of students in their classrooms
    classroom_ids = current_user.classrooms_taught.ids
    student_ids = Student.where(classroom_id: classroom_ids).ids
    parent.students_as_parent.where(id: student_ids).exists?
  end

  def can_edit_parent?(parent)
    current_user.admin? # Only admins can edit parent accounts
  end
end