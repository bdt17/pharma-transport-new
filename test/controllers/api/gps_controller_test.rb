require "test_helper"

class Api::GpsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get api_gps_index_url
    assert_response :success
  end

  test "should get show" do
    get api_gps_show_url
    assert_response :success
  end
end
