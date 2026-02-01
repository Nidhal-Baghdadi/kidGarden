class PhotosController < ApplicationController
  before_action :authenticate_user!
  before_action :set_photo, only: %i[show edit update destroy approve]
  before_action :set_students_for_forms, only: %i[new create edit update]
  before_action :set_filters, only: %i[index gallery]

  # GET /photos
  def index
    @photos =
      Photo.accessible_by(current_user)
           .includes(:student, :uploaded_by, :classroom, image_attachment: :blob)
           .order(created_at: :desc)

    @photos = apply_filters(@photos)

    # Pagination (only if your paginator exists)
    @photos = @photos.page(params[:page]).per(20) if @photos.respond_to?(:page)
  end

  # GET /photos/gallery
  def gallery
    @photos =
      Photo.accessible_by(current_user)
           .where(approved: true)
           .includes(:student, :uploaded_by, image_attachment: :blob)
           .order(created_at: :desc)

    @photos = apply_filters(@photos)

    @photos = @photos.page(params[:page]).per(12) if @photos.respond_to?(:page)
  end

  # GET /photos/:id
  def show
    unless @photo.accessible_by?(current_user)
      redirect_to photos_path, alert: "You don't have permission to view this photo."
      return
    end
  end

  # GET /photos/new
  def new
    unless can_upload_photos?
      redirect_to photos_path, alert: "You don't have permission to upload photos."
      return
    end

    @photo = Photo.new
  end

  # POST /photos
  def create
    unless can_upload_photos?
      redirect_to photos_path, alert: "You don't have permission to upload photos."
      return
    end

    @photo = Photo.new(photo_params)
    @photo.uploaded_by = current_user

    if @photo.save
      notify_parents_if_needed(@photo)
      redirect_to @photo, notice: "Photo was successfully uploaded."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /photos/:id/edit
  def edit
    unless can_edit_photo?(@photo)
      redirect_to photos_path, alert: "You don't have permission to edit this photo."
      return
    end
  end

  # PATCH/PUT /photos/:id
  def update
    unless can_edit_photo?(@photo)
      redirect_to photos_path, alert: "You don't have permission to update this photo."
      return
    end

    if @photo.update(photo_params)
      redirect_to @photo, notice: "Photo was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /photos/:id
  def destroy
    unless can_edit_photo?(@photo)
      redirect_to photos_path, alert: "You don't have permission to delete this photo."
      return
    end

    @photo.destroy
    redirect_to photos_path, notice: "Photo was successfully deleted."
  end

  # PATCH /photos/:id/approve
  def approve
    unless current_user.admin? || current_user.teacher?
      redirect_to photos_path, alert: "You don't have permission to approve photos."
      return
    end

    @photo.update(approved: true)
    redirect_to @photo, notice: "Photo approved successfully."
  end

  private

  def set_photo
    @photo = Photo.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to photos_path, alert: "Photo not found."
    @photo = nil
  end

  def set_students_for_forms
    @students = accessible_students.order(:first_name, :last_name)
  end

  def set_filters
    @accessible_students = accessible_students.order(:first_name, :last_name)
    @accessible_classrooms = accessible_classrooms.order(:name)
  end

  def photo_params
    # supports either `:image` (single) or `:images` if you later add multi
    params.require(:photo).permit(
      :student_id, :classroom_id, :title, :description, :category,
      :visible_to_parents, :image, :taken_at
    )
  end

  # ------- Filtering (safe + permission-aware) -------

  def apply_filters(scope)
    scope = filter_by_student(scope)
    scope = filter_by_classroom(scope)
    scope = filter_by_category(scope)
    scope = filter_by_date_range(scope)
    scope
  end

  def filter_by_student(scope)
    return scope unless params[:student_id].present?

    student = accessible_students.find_by(id: params[:student_id])
    return scope unless student

    scope.by_student(student)
  end

  def filter_by_classroom(scope)
    return scope unless params[:classroom_id].present?

    classroom = accessible_classrooms.find_by(id: params[:classroom_id])
    return scope unless classroom

    scope.by_classroom(classroom)
  end

  def filter_by_category(scope)
    return scope unless params[:category].present?

    scope.where(category: params[:category])
  end

  def filter_by_date_range(scope)
    return scope unless params[:start_date].present? && params[:end_date].present?

    begin
      start_date = Date.parse(params[:start_date])
      end_date = Date.parse(params[:end_date]).end_of_day
      scope.where(created_at: start_date..end_date)
    rescue ArgumentError
      scope
    end
  end

  # ------- Access rules (centralized) -------

  def can_upload_photos?
    current_user.admin? || current_user.teacher?
  end

  def can_edit_photo?(photo)
    current_user.admin? || photo.uploaded_by == current_user
  end

  def accessible_students
    case current_user.role
    when "admin"
      Student.all
    when "teacher"
      Student.joins(:classroom).where(classrooms: { teacher_id: current_user.id })
    when "parent"
      current_user.students_as_parent
    else
      Student.none
    end
  end

  def accessible_classrooms
    case current_user.role
    when "admin"
      Classroom.all
    when "teacher"
      current_user.classrooms_taught
    when "parent"
      # classrooms that contain any of my children
      Classroom.joins(:students).where(students: { id: current_user.students_as_parent.select(:id) }).distinct
    else
      Classroom.none
    end
  end

  # ------- Notifications -------

  def notify_parents_if_needed(photo)
    return unless photo.visible_to_parents?
    return unless photo.student

    parents = photo.student.all_parents
    return if parents.blank?

    parents.each do |parent|
      NotificationService.send_notification(
        recipient: parent,
        title: "New Photo of #{photo.student.first_name}",
        message: "A new photo titled '#{photo.title}' has been added to #{photo.student.first_name}'s gallery.",
        notification_type: "event", # keep your current type unless you add "photo"
        sender: current_user,
        link: photo_path(photo)
      )
    end
  rescue StandardError
    # don’t break upload due to notification failures
    nil
  end
end
