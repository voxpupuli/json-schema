require 'test/unit'
require File.expand_path('../../lib/json-schema', __FILE__)

class CommonTestSuiteTest < Test::Unit::TestCase
  TEST_DIR = File.expand_path('../test-suite/tests', __FILE__)

  # These are test files which we know fail spectacularly, either because
  # we don't support that functionality or because they require external
  # dependencies
  IGNORED_TESTS = [
    "draft3/disallow.json",
    "draft3/optional/format.json",
    "draft3/optional/jsregex.json",
    "draft3/refRemote.json",
    "draft4/optional/format.json",
    "draft4/refRemote.json",
  ]

  Dir["#{TEST_DIR}/*"].each do |suite|
    version = File.basename(suite).to_sym
    Dir["#{suite}/**/*.json"].each do |tfile|
      test_list = JSON::Validator.parse(File.read(tfile))
      rel_file = tfile[TEST_DIR.length+1..-1]

      test_list.each do |test|
        schema = test["schema"]
        base_description = test["description"]
        v = nil

        test["tests"].each do |t|
          err_id = "#{rel_file}, '#{base_description}'/'#{t['description']}'"

          define_method("test_#{err_id}") do
            skip "Known incompatibility with common test suite" if IGNORED_TESTS.include?(rel_file)

            assert_nothing_raised("Exception raised running #{err_id}") do
              v = JSON::Validator.fully_validate(schema,
                                                 t["data"],
                                                 :validate_schema => true,
                                                 :version => version
                                                )
            end

            assert v.empty? == t["valid"], "Common test suite case failed: #{err_id}\n#{v}"
          end
        end
      end
    end
  end
end
