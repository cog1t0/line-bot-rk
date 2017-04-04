require 'test_helper'

class SampleControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get sample_index_url
    assert_response :success
  end

end
