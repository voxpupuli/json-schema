require File.expand_path('support/test_helper', __dir__)

class MultiJsonUsageTest < Minitest::Test
  def setup
    @original_use_multi_json = JSON::Validator.use_multi_json?
  end

  def teardown
    JSON::Validator.use_multi_json = @original_use_multi_json
  end

  def test_use_multi_json_is_disabled_by_default_in_tests
    assert_equal(false, JSON::Validator.use_multi_json?)
  end

  def test_json_backend_changes_when_multi_json_is_disabled
    JSON::Validator.use_multi_json = true
    assert_equal(MultiJson::Adapters::JsonGem, JSON::Validator.json_backend)

    JSON::Validator.use_multi_json = false
    assert_equal('json', JSON::Validator.json_backend)
  end
end
