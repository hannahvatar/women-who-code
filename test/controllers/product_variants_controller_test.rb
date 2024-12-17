require "test_helper"

class ProductVariantsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get product_variants_index_url
    assert_response :success
  end
end
