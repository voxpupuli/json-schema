# frozen_string_literal: true

begin
  require 'simplecov'
  require 'simplecov-console'
  require 'simplecov-lcov'
  if ENV['COVERAGE'] == 'yes'
    require 'codecov'
  end
rescue LoadError => e
  puts "Load error: #{e}"
else
  SimpleCov.start do
    puts "Starting!"
    track_files 'lib/**/*.rb'

    add_filter '/test'

    enable_coverage :branch

    # do not track vendored files
    add_filter '/vendor'
    add_filter '/.vendor'
  end

  if ENV['LOCAL_COVERAGE'] == 'yes'
    SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true
    SimpleCov::Formatter::LcovFormatter.config.single_report_path = 'coverage/lcov.info'
    SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
      SimpleCov::Formatter::HTMLFormatter,
      SimpleCov::Formatter::LcovFormatter
    ])
  else
    SimpleCov.formatters = [
      SimpleCov::Formatter::Console,
      SimpleCov::Formatter::Codecov,
    ]
  end


end

require 'minitest/autorun'
require 'webmock/minitest'

$LOAD_PATH.unshift(File.expand_path('../../../lib', __FILE__))
require 'json-schema'

Dir[File.join(File.expand_path('../', __FILE__), '*.rb')].each do |support_file|
  require support_file unless support_file == __FILE__
end

class Minitest::Test
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
    assert_equal([], errors, msg)
  end

  def refute_valid(schema, data, options = {}, msg = "#{data.inspect} should be invalid for schema:\n#{schema.inspect}")
    errors = validation_errors(schema, data, options)
    refute_equal([], errors, msg)
  end

  def validation_errors(schema, data, options)
    options = { :clear_cache => true, :validate_schema => true }.merge(options)
    JSON::Validator.fully_validate(schema, data, options)
  end
end
