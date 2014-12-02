require 'rubygems'

require 'json'
require 'json-schema/util/array_set'
require 'json-schema/schema'
require 'json-schema/validator'

Dir[File.join(File.dirname(__FILE__), "json-schema/attributes/*.rb")].each {|file| require file }
Dir[File.join(File.dirname(__FILE__), "json-schema/attributes/formats/*.rb")].each {|file| require file }
Dir[File.join(File.dirname(__FILE__), "json-schema/validators/*.rb")].sort!.each {|file| require file }
