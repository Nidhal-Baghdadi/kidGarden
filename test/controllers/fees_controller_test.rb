require "test_helper"

class FeesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get fees_index_url
    assert_response :success
  end

  test "should get show" do
    get fees_show_url
    assert_response :success
  end

  test "should get new" do
    get fees_new_url
    assert_response :success
  end

  test "should get create" do
    get fees_create_url
    assert_response :success
  end

  test "should get edit" do
    get fees_edit_url
    assert_response :success
  end

  test "should get update" do
    get fees_update_url
    assert_response :success
  end

  test "should get destroy" do
    get fees_destroy_url
    assert_response :success
  end
end
