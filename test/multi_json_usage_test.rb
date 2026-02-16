require File.expand_path('support/test_helper', __dir__)

class MultiJsonUsageTest < Minitest::Test
  def setup
    @original_use_multi_json = JSON::Validator.use_multi_json?
    JSON::Validator.send(:reset_multi_json_deprecation_warning!)
  end

  def teardown
    JSON::Validator.use_multi_json = @original_use_multi_json
    JSON::Validator.send(:reset_multi_json_deprecation_warning!)
  end

  def test_use_multi_json_is_disabled_by_default_in_tests
    refute_predicate(JSON::Validator, :use_multi_json?)
  end

  def test_json_backend_changes_when_multi_json_is_disabled
    JSON::Validator.use_multi_json = true

    suppress_warnings do
      assert_equal(MultiJson::Adapters::JsonGem, JSON::Validator.json_backend)
    end

    JSON::Validator.use_multi_json = false

    assert_equal('json', JSON::Validator.json_backend)
  end

  def test_deprecation_warning_when_multi_json_is_used
    JSON::Validator.use_multi_json = true

    _out, err = capture_io do
      JSON::Validator.json_backend
    end

    assert_match(/DEPRECATION NOTICE/, err)
    assert_match(/MultiJSON is deprecated/, err)
  end
end
