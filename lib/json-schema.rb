require 'rubygems'

require 'json-schema/util/array_set'
require 'json-schema/util/uri'
require 'json-schema/schema'
require 'json-schema/schema/reader'
require 'json-schema/validator'

Dir[File.join(File.dirname(__FILE__), 'json-schema/attributes/**/*.rb')].sort.each { |file| require file }
Dir[File.join(File.dirname(__FILE__), 'json-schema/validators/*.rb')].sort!.each { |file| require file }
