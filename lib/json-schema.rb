require 'multi_json'
# Force MultiJson to load an engine before we define the JSON constant here; otherwise,
# it looks for things that are under the JSON namespace that aren't there (since we have defined it here)
MultiJson.engine

$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/json-schema"

require 'rubygems'
require 'schema'
require 'validator'
Dir[File.join(File.dirname(__FILE__), "json-schema/attributes/*.rb")].each {|file| require file }
Dir[File.join(File.dirname(__FILE__), "json-schema/validators/*.rb")].each {|file| require file }
require 'uri/file'
