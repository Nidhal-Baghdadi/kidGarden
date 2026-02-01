class StudentsController < ApplicationController
  before_action :set_student, only: [:show, :edit, :update, :destroy]

  def index
    respond_to do |format|
      format.html
      format.json { render json: StudentsDatatable.new(params, view_context: view_context) }
    end
  end

  def show
    # Allow access based on role
    unless can_access_student?(@student)
      redirect_to root_path, alert: "You don't have permission to view this student."
      return
    end
  end

  def new
    @student = Student.new
  end

  def create
    @student = Student.new(student_params)

    # Only allow parents to create students for their children
    if current_user.parent?
      @student.parent = current_user
    end

    if @student.save
      redirect_to @student, notice: 'Student was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    # Allow access based on role
    unless can_access_student?(@student)
      redirect_to root_path, alert: "You don't have permission to edit this student."
      return
    end
  end

  def update
    # Allow access based on role
    unless can_access_student?(@student)
      redirect_to root_path, alert: "You don't have permission to update this student."
      return
    end

    if @student.update(student_params)
      redirect_to @student, notice: 'Student was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    # Allow access based on role
    unless can_access_student?(@student)
      redirect_to root_path, alert: "You don't have permission to delete this student."
      return
    end

    @student.destroy
    redirect_to students_url, notice: 'Student was successfully deleted.'
  end

  private
    def set_student
      @student = Student.find(params[:id])
    end

    def student_params
      params.require(:student).permit(:first_name, :last_name, :date_of_birth, :enrollment_date, :status, :gender, :emergency_contact_name, :emergency_contact_phone, :medical_information, :parent_id, :classroom_id)
    end

    def can_access_student?(student)
      current_user.admin? ||
      (current_user.teacher? && current_user.classrooms_taught.include?(student.classroom)) ||
      (current_user.parent? && student.parent == current_user)
    end
end
