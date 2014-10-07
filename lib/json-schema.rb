require 'rubygems'

if begin
  Gem::Specification::find_by_name('multi_json')
  rescue Gem::LoadError
    false
  rescue
    Gem.available?('multi_json')
  end
  require 'multi_json'

  # Force MultiJson to load an engine before we define the JSON constant here; otherwise,
  # it looks for things that are under the JSON namespace that aren't there (since we have defined it here)
  MultiJson.respond_to?(:adapter) ? MultiJson.adapter : MultiJson.engine
end

require 'rubygems'
require 'json-schema/util/hash'
require 'json-schema/util/array_set'
require 'json-schema/schema'
require 'json-schema/validator'
# why is this needed/where are the other errors required?
require 'json-schema/errors/custom_format_error'
Dir[File.join(File.dirname(__FILE__), "json-schema/attributes/*.rb")].each {|file| require file }
Dir[File.join(File.dirname(__FILE__), "json-schema/attributes/formats/*.rb")].each {|file| require file }
Dir[File.join(File.dirname(__FILE__), "json-schema/validators/*.rb")].sort!.each {|file| require file }
require 'json-schema/uri/file'
