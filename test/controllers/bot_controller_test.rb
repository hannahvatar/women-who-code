require "test_helper"

class BotControllerTest < ActionDispatch::IntegrationTest
  test "should get ask" do
    get bot_ask_url
    assert_response :success
  end
end
