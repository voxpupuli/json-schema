if ENV['CI'].to_s == 'true'
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
end

require 'minitest/autorun'
require 'webmock/minitest'

WebMock.disable_net_connect!

Minitest.after_run do
  # make sure webmock does not prevent posting to code climate
  WebMock.allow_net_connect!
end

$:.unshift(File.expand_path('../../lib', __FILE__))
require 'json-schema'

Dir[File.join(File.expand_path('../support', __FILE__), '*.rb')].each do |support_file|
  require support_file
end

class Minitest::Test
  def schema_fixture_path(filename)
    File.join(File.dirname(__FILE__), 'schemas', filename)
  end

  def data_fixture_path(filename)
    File.join(File.dirname(__FILE__), 'data', filename)
  end

  def assert_valid(schema, data, options = {})
    if !options.key?(:version) && respond_to?(:schema_version)
      options = options.merge(:version => schema_version)
    end

    errors = JSON::Validator.fully_validate(schema, data, options)
    assert_equal([], errors, "#{data.inspect} should be valid for schema:\n#{schema.inspect}")
  end

  def refute_valid(schema, data, options = {})
    if !options.key?(:version) && respond_to?(:schema_version)
      options = options.merge(:version => schema_version)
    end

    errors = JSON::Validator.fully_validate(schema, data, options)
    refute_equal([], errors, "#{data.inspect} should be invalid for schema:\n#{schema.inspect}")
  end
end
