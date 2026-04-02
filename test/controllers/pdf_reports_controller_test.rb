require "test_helper"

class PdfReportsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get pdf_reports_show_url
    assert_response :success
  end
end
