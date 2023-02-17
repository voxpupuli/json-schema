require File.expand_path('../support/test_helper', __FILE__)
require 'json'

class CommonTestSuiteTest < Minitest::Test
  TEST_DIR = File.expand_path('../test-suite/tests', __FILE__)

  IGNORED_TESTS = YAML.load_file(File.expand_path('../support/test_suite_ignored_tests.yml', __FILE__))

  def setup
    Dir["#{TEST_DIR}/../remotes/**/*.json"].each do |path|
      schema = path.sub(%r{^.*/remotes/}, '')
      stub_request(:get, "http://localhost:1234/#{schema}")
        .to_return(body: File.read(path), status: 200)
    end
  end

  def self.skip?(current_test, file_path)
    skipped_in_file = file_path.chomp('.json').split('/').inject(IGNORED_TESTS) do |ignored, path_component|
      ignored.nil? ? nil : ignored[path_component]
    end

    !skipped_in_file.nil? && (skipped_in_file == :all || skipped_in_file.include?(current_test))
  end

  Dir["#{TEST_DIR}/*"].each do |suite|
    version = File.basename(suite).to_sym
    Dir["#{suite}/**/*.json"].each do |tfile|
      test_list = JSON.parse(File.read(tfile))
      rel_file = tfile[TEST_DIR.length + 1..-1]

      test_list.each do |test|
        schema = test['schema']
        base_description = test['description']

        test['tests'].each do |t|
          full_description = "#{base_description}/#{t['description']}"

          next if rel_file.include?('/optional/') && skip?(full_description, rel_file)

          err_id = "#{rel_file}: #{full_description}"
          define_method("test_#{err_id}") do
            skip if self.class.skip?(full_description, rel_file)

            errors = JSON::Validator.fully_validate(schema,
                                                    t['data'],
                                                    parse_data: false,
                                                    validate_schema: true,
                                                    version: version,
                                                   )
            assert_equal t['valid'], errors.empty?, "Common test suite case failed: #{err_id}"
          end
        end
      end
    end
  end
end
