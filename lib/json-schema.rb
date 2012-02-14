require 'rubygems'

def load_gem gemname
  if begin
    Gem::Specification::find_by_name(gemname)
    rescue Gem::LoadError
      false
    rescue
      Gem.available?(gemname)
    end
    require gemname
  end
end

load_gem('yajl')
load_gem('json')

require File.join(File.dirname(__FILE__),"json-schema/lib/multi_json/multi_json.rb")

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