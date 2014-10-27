require 'simplecov' unless ENV['COVERAGE'] == 'false'
require 'test/unit'

$:.unshift(File.expand_path('../../lib', __FILE__))
require 'json-schema'
