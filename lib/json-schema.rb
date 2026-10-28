require 'rubygems'

if Gem::Specification.find_all_by_name('multi_json').any?
  require 'multi_json'

  # Force MultiJson to load an engine before we define the JSON constant here; otherwise,
  # it looks for things that are under the JSON namespace that aren't there (since we have defined it here)
  # multi_json 1.21 renamed MultiJson to MultiJSON and warns whenever the old name is used.
  multi_json = defined?(MultiJSON) ? MultiJSON : MultiJson
  multi_json.respond_to?(:adapter) ? multi_json.adapter : multi_json.engine
end

require 'json-schema/util/array_set'
require 'json-schema/util/uri'
require 'json-schema/schema'
require 'json-schema/schema/reader'
require 'json-schema/validator'

Dir[File.join(File.dirname(__FILE__), 'json-schema/attributes/**/*.rb')].sort.each { |file| require file }
Dir[File.join(File.dirname(__FILE__), 'json-schema/validators/*.rb')].sort!.each { |file| require file }
