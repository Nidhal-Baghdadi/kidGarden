class PhotosController < ApplicationController
  before_action :authenticate_user!
  before_action :set_photo, only: [:show, :edit, :update, :destroy, :approve]

  def index
    # Get photos based on user role and permissions
    @photos = Photo.accessible_by(current_user)
                  .includes(:student, :uploaded_by, :classroom)
                  .order(created_at: :desc)

    # Set accessible students for the filter dropdown
    @accessible_students = get_accessible_students

    # Filter by student if specified
    if params[:student_id].present?
      student = Student.find(params[:student_id])
      @photos = @photos.by_student(student) if can_view_student_photos?(student)
    end

    # Filter by classroom if specified
    if params[:classroom_id].present?
      classroom = Classroom.find(params[:classroom_id])
      @photos = @photos.by_classroom(classroom) if can_view_classroom_photos?(classroom)
    end

    # Filter by date range if specified
    if params[:start_date].present? && params[:end_date].present?
      start_date = Date.parse(params[:start_date])
      end_date = Date.parse(params[:end_date]).end_of_day
      @photos = @photos.where(created_at: start_date..end_date)
    end

    # Filter by category if specified
    if params[:category].present?
      @photos = @photos.where(category: params[:category])
    end

    # Pagination
    @photos = @photos.page(params[:page]).per(20)
  end

  def show
    # Check if user has permission to view this photo
    unless @photo.accessible_by?(current_user)
      redirect_to photos_path, alert: "You don't have permission to view this photo."
      return
    end

    # Render the show template
  end

  def new
    @photo = Photo.new
    @students = get_accessible_students
  end

  def create
    @photo = Photo.new(photo_params)
    @photo.uploaded_by = current_user

    if @photo.save
      # Send notification to parents if photo is visible to them
      if @photo.visible_to_parents?
        parents = @photo.student.all_parents
        parents.each do |parent|
          NotificationService.send_notification(
            recipient: parent,
            title: "New Photo of #{@photo.student.first_name}",
            message: "A new photo titled '#{@photo.title}' has been added to #{@photo.student.first_name}'s gallery.",
            notification_type: 'event',
            sender: current_user,
            link: photo_path(@photo)
          )
        end
      end

      redirect_to @photo, notice: 'Photo was successfully uploaded.'
    else
      @students = get_accessible_students
      render :new
    end
  end

  def edit
    # Only allow editing if user uploaded the photo or is admin
    unless can_edit_photo?(@photo)
      redirect_to photos_path, alert: "You don't have permission to edit this photo."
      return
    end

    @students = get_accessible_students
  end

  def update
    # Only allow updating if user uploaded the photo or is admin
    unless can_edit_photo?(@photo)
      redirect_to photos_path, alert: "You don't have permission to update this photo."
      return
    end

    if @photo.update(photo_params)
      redirect_to @photo, notice: 'Photo was successfully updated.'
    else
      @students = get_accessible_students
      render :edit
    end
  end

  def destroy
    # Only allow deleting if user uploaded the photo or is admin
    unless can_edit_photo?(@photo)
      redirect_to photos_path, alert: "You don't have permission to delete this photo."
      return
    end

    @photo.destroy
    redirect_to photos_path, notice: 'Photo was successfully deleted.'
  end

  def approve
    # Only admins and teachers can approve photos
    unless current_user.admin? || current_user.teacher?
      redirect_to photos_path, alert: "You don't have permission to approve photos."
      return
    end

    @photo.update(approved: true)
    redirect_to @photo, notice: 'Photo approved successfully.'
  end

  def gallery
    # Gallery view showing photos in a grid layout
    @photos = Photo.accessible_by(current_user)
                  .where(approved: true)
                  .includes(:student, :uploaded_by)
                  .order(created_at: :desc)
    
    # Filter by student if specified
    if params[:student_id].present?
      student = Student.find(params[:student_id])
      @photos = @photos.by_student(student) if can_view_student_photos?(student)
    end
    
    # Filter by classroom if specified
    if params[:classroom_id].present?
      classroom = Classroom.find(params[:classroom_id])
      @photos = @photos.by_classroom(classroom) if can_view_classroom_photos?(classroom)
    end
    
    # Pagination
    @photos = @photos.page(params[:page]).per(12) # 12 photos per page for gallery view
  end

  private

  def set_photo
    @photo = Photo.find(params[:id])
  end

  def photo_params
    params.require(:photo).permit(:student_id, :classroom_id, :title, :description, :category, :visible_to_parents, :image, :taken_at)
  end

  def get_accessible_students
    case current_user.role
    when 'admin'
      Student.all
    when 'teacher'
      # Teachers can access students in their classrooms
      Student.joins(:classroom).where(classrooms: { teacher_id: current_user.id })
    when 'parent'
      # Parents can only access their own children
      current_user.students_as_parent
    else
      Student.none
    end
  end

  def can_view_student_photos?(student)
    case current_user.role
    when 'admin'
      true
    when 'teacher'
      student.classroom&.teacher == current_user
    when 'parent'
      current_user.students_as_parent.include?(student)
    else
      false
    end
  end

  def can_view_classroom_photos?(classroom)
    case current_user.role
    when 'admin'
      true
    when 'teacher'
      classroom.teacher == current_user
    when 'parent'
      classroom.students.joins(:parent_student_relationships)
                       .where(parent_student_relationships: { parent_id: current_user.id }).exists?
    else
      false
    end
  end

  def can_edit_photo?(photo)
    current_user.admin? || photo.uploaded_by == current_user
  end
end