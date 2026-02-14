require "test_helper"

class WeeksControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get weeks_show_url
    assert_response :success
  end

  test "should get create" do
    get weeks_create_url
    assert_response :success
  end
end
