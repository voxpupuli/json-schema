require 'test/unit'

$:.unshift(File.expand_path('../../lib', __FILE__))
require 'json-schema'

class Test::Unit::TestCase
  def schema_fixture_path(filename)
    File.join(File.dirname(__FILE__), 'schemas', filename)
  end

  def data_fixture_path(filename)
    File.join(File.dirname(__FILE__), 'data', filename)
  end

  def assert_valid(schema, data, options = {})
    errors = JSON::Validator.fully_validate(schema, data, options)
    assert_equal([], errors, "#{data.inspect} should be valid for schema:\n#{schema.inspect}")
  end

  def refute_valid(schema, data, options = {})
    errors = JSON::Validator.fully_validate(schema, data, options)
    refute_equal([], errors, "#{data.inspect} should be invalid for schema:\n#{schema.inspect}")
  end
end
