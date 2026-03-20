require "test_helper"

class PaymentsControllerTest < ActionDispatch::IntegrationTest
  test "should get checkout" do
    get payments_checkout_url
    assert_response :success
  end

  test "should get create_payment_intent" do
    get payments_create_payment_intent_url
    assert_response :success
  end

  test "should get webhook" do
    get payments_webhook_url
    assert_response :success
  end
end
