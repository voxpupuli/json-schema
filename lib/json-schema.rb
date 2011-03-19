$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/json-schema"

require 'rubygems'
require 'schema'
require 'validator'
Dir[File.join(File.dirname(__FILE__), "json-schema/attributes/*")].each {|file| require file }
Dir[File.join(File.dirname(__FILE__), "json-schema/validators/*")].each {|file| require file }
require 'uri/file'
require 'uri/uuid'