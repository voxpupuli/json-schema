# frozen_string_literal: true

require 'minitest/autorun'
require 'webmock/minitest'

Minitest.load_plugins
require 'minitest/reporters'

if ENV['GITHUB_ACTIONS'] == 'true'
  require 'minitest_reporters_github'
  Minitest::Reporters.use!([MinitestReportersGithub.new])
else
  Minitest::Reporters.use!
end

$LOAD_PATH.unshift(File.expand_path('../../lib', __dir__))
require 'json-schema'

Dir[File.join(File.expand_path(__dir__), '*.rb')].sort.each do |support_file|
  require support_file unless support_file == __FILE__
end

module Minitest
  class Test
    def suppress_warnings
      old_verbose = $VERBOSE
      $VERBOSE = nil
      begin
        yield
      ensure
        $VERBOSE = old_verbose
      end
    end

    def schema_fixture_path(filename)
      File.join(File.dirname(__FILE__), '../schemas', filename)
    end

    def data_fixture_path(filename)
      File.join(File.dirname(__FILE__), '../data', filename)
    end

    def assert_valid(schema, data, options = {}, msg = "#{data.inspect} should be valid for schema:\n#{schema.inspect}")
      errors = validation_errors(schema, data, options)

      assert_empty(errors, msg)
    end

    def refute_valid(schema, data, options = {}, msg = "#{data.inspect} should be invalid for schema:\n#{schema.inspect}")
      errors = validation_errors(schema, data, options)

      refute_equal([], errors, msg)
    end

    def validation_errors(schema, data, options)
      options = { clear_cache: true, validate_schema: true }.merge(options)
      JSON::Validator.fully_validate(schema, data, options)
    end
  end
end
