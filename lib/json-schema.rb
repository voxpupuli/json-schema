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

$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/json-schema"

require 'rubygems'
require 'schema'
require 'validator'
Dir[File.join(File.dirname(__FILE__), "json-schema/attributes/*.rb")].each {|file| require file }
Dir[File.join(File.dirname(__FILE__), "json-schema/validators/*.rb")].each {|file| require file }
require 'uri/file'
