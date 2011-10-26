require 'test_helper'

class AuthControllerTest < ActionController::TestCase
  test "should get begin" do
    get :begin
    assert_response :success
  end

  test "should get complete" do
    get :complete
    assert_response :success
  end

end
