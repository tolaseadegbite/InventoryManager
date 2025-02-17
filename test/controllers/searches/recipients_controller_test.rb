require "test_helper"

class Searches::RecipientsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get searches_recipients_show_url
    assert_response :success
  end
end
