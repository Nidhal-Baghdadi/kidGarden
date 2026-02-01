module StudentsHelper
  def decorate_student(student)
    StudentDecorator.new(student)
  end
end
