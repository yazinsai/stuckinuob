require 'test_helper'

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get "/"
    assert_response :success
  end
  
  test "should get check" do
    # get "/check?courses[]=1&courses[]=2"
    # assert_response :success
  end

end
