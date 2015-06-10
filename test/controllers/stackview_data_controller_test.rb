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

  test "configured :link filter" do
    StackviewDataController.set_config_for_type("test", 
      :link => lambda do |hash|
        "http://example.org/to_doc/#{hash['system_id']}"
      end
    )

    get :fetch, :call_number_type => "test", :query => "[1 TO 10]"
    
    docs = JSON.parse( response.body )["docs"]

    docs.each do |doc|
      assert_equal "http://example.org/to_doc/#{doc['system_id']}", doc['link']
    end
  end

  class StackviewDataControllerConfigTest < ActionController::TestCase

    test "has and can look up config for `lc`" do
      config = StackviewDataController.config_for_type('lc')
      assert_present config

      assert_present config[:fetch_adapter]
    end

    test "can set config" do
      StackviewDataController.set_config_for_type("just_testing", :foo => :bar)

      config = StackviewDataController.config_for_type('just_testing')
      assert_present config

      assert_equal :bar, config[:foo]

      StackviewDataController.remove_config_for_type("just_testing")
    end
  end

end
