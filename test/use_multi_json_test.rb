require File.expand_path('support/test_helper', __dir__)

class UseMultiJsonTest < Minitest::Test
  def test_setting_use_multi_json_raises
    [true, false].each do |value|
      error = assert_raises(ArgumentError) { JSON::Validator.use_multi_json = value }
      assert_match(/no longer supports MultiJSON/, error.message)
    end
  end
end
