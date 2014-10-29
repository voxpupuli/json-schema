require 'test/unit'
require File.expand_path('../../lib/json-schema', __FILE__)

class CommonTestSuiteTest < Test::Unit::TestCase
  TEST_DIR = File.expand_path('../test-suite/tests', __FILE__)

  # These are test files which we know fail spectacularly, either because we
  # don't support that functionality or because they require external
  # dependencies.  To allow finer-grained control over which tests to run,
  # you can replace `:all` with an array containing the names of individual
  # tests to skip.
  IGNORED_TESTS = Hash.new { |h,k| h[k] = [] }.merge({
    "draft3/disallow.json" => :all,
    "draft3/optional/format.json" => :all,
    "draft3/optional/jsregex.json" => [
      "ECMA 262 regex dialect recognition/ECMA 262 has no support for lookbehind",
      "ECMA 262 regex dialect recognition/[^] is a valid regex",
    ],
    "draft3/refRemote.json" => :all,
    "draft4/optional/format.json" => :all,
    "draft4/refRemote.json" => :all,
  })

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
          err_id = "#{rel_file}: #{base_description}/#{t['description']}"

          define_method("test_#{err_id}") do
            if IGNORED_TESTS[rel_file] == :all or
               IGNORED_TESTS[rel_file].include? "#{base_description}/#{t['description']}"
              skip "Known issue"
            end

            assert_nothing_raised("Exception raised running #{err_id}") do
              v = JSON::Validator.fully_validate(schema,
                                                 t["data"],
                                                 :validate_schema => true,
                                                 :version => version
                                                )
            end

            assert_equal t["valid"], v.empty?, "Common test suite case failed: #{err_id}\n#{v}"
          end
        end
      end
    end
  end
end
