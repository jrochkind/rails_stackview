require 'test_helper'
require 'json'

class StackviewDataControllerTest < ActionController::TestCase
  test "fetch with test adapter" do
    get :fetch, :call_number_type => "test", :query => "[-5 TO 5]"

    assert_response :success
    assert_equal "application/json", response.content_type
    
    parsed_response = JSON.parse( response.body )

    assert_kind_of Array, (docs = parsed_response["docs"])

    assert_equal 11, docs.length
  end

end
