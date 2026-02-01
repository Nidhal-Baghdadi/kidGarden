class ResourcesController < ApplicationController
  before_action :set_resource, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  def index
    scope = Resource.includes(:classroom, :user).order(created_at: :desc)

    # Optional: add light filtering/search without DataTables
    if params[:q].present?
      q = params[:q].strip
      scope = scope.where("resources.title ILIKE :q OR resources.subject ILIKE :q OR resources.category ILIKE :q", q: "%#{q}%")
    end

    if params[:category].present?
      scope = scope.where(category: params[:category])
    end

    if params[:classroom_id].present?
      scope = scope.where(classroom_id: params[:classroom_id])
    end

    @resources = scope
  end

  def show
  end

  def new
    authorize_create!
    @resource = Resource.new
  end

  def create
    authorize_create!
    @resource = Resource.new(resource_params)
    @resource.user = current_user

    if @resource.save
      redirect_to @resource, notice: "Resource was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize_owner_or_admin!
  end

  def update
    authorize_owner_or_admin!
    if @resource.update(resource_params)
      redirect_to @resource, notice: "Resource was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize_owner_or_admin!
    @resource.destroy
    redirect_to resources_path, notice: "Resource was successfully deleted."
  end

  private

  def set_resource
    @resource = Resource.find(params[:id])
  end

  def resource_params
    params.require(:resource).permit(:title, :description, :category, :classroom_id, :subject, :file)
  end

  def authorize_create!
    unless current_user.admin? || current_user.teacher?
      redirect_to resources_path, alert: "You don't have permission to create resources."
    end
  end

  def authorize_owner_or_admin!
    unless current_user.admin? || current_user.id == @resource.user_id
      redirect_to resources_path, alert: "You don't have permission to modify this resource."
    end
  end
end
