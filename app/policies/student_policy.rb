# Policy class for Student model authorization
class StudentPolicy
  def initialize(user, student)
    @user = user
    @student = student
  end

  def show?
    admin? || teacher? || parent_of_student?
  end

  def create?
    admin? || teacher?
  end

  def update?
    admin? || teacher? || (parent_of_student? && child_enrolled?)
  end

  def destroy?
    admin? || teacher?
  end

  private

  def admin?
    @user&.role == 'admin'
  end

  def teacher?
    @user&.role == 'teacher'
  end

  def parent_of_student?
    @user&.role == 'parent' && @student.parent_id == @user.id
  end

  def child_enrolled?
    @student.enrolled?
  end
end