class ParentStudentRelationshipsController < ApplicationController
  def create
    @relationship = ParentStudentRelationship.new(relationship_params)

    if @relationship.save
      redirect_to student_path(@relationship.student), notice: 'Parent was successfully added to the student.'
    else
      # We'll need to handle errors differently since this is likely accessed from the student page
      student = Student.find(relationship_params[:student_id])
      redirect_to student_path(student), alert: "Error adding parent: #{@relationship.errors.full_messages.join(', ')}"
    end
  end

  def destroy
    @relationship = ParentStudentRelationship.find(params[:id])
    @student = @relationship.student
    @relationship.destroy

    redirect_to student_path(@student), notice: 'Parent relationship was successfully removed.'
  end

  private

  def relationship_params
    params.require(:parent_student_relationship).permit(:student_id, :parent_id, :relationship_type, :contact_priority, :active)
  end
end
