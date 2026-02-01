require "test_helper"

class ParentStudentRelationshipsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get parent_student_relationships_create_url
    assert_response :success
  end

  test "should get destroy" do
    get parent_student_relationships_destroy_url
    assert_response :success
  end
end
