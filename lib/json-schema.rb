$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/json-schema"

require 'rubygems'
require 'schema'
require 'validator'
Dir[File.join(File.dirname(__FILE__), "json-schema/attributes/*.rb")].each {|file| require file }
Dir[File.join(File.dirname(__FILE__), "json-schema/validators/*.rb")].each {|file| require file }
require 'uri/file'
