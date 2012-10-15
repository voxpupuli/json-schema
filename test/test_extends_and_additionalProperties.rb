require 'test/unit'
require File.dirname(__FILE__) + '/../lib/json-schema'

class ExtendsNestedTest < Test::Unit::TestCase

  def assert_validity(valid, schema_name, data, msg=nil)
    file = File.expand_path("../schemas/#{schema_name}.schema.json",__FILE__)
    errors = JSON::Validator.fully_validate file, data
    msg.sub! /\.$/, '' if msg
    send (valid ? :assert_equal : :assert_not_equal), [], errors, \
      "Schema should be #{valid ? :valid : :invalid}#{msg ? ".\n[#{schema_name}] #{msg}" : ''}"
  end

  def assert_valid(schema_name, data, msg=nil) assert_validity true, schema_name, data, msg end
  def refute_valid(schema_name, data, msg=nil) assert_validity false, schema_name, data, msg end

  %w[
    extends_and_additionalProperties-1-filename extends_and_additionalProperties-1-ref
    extends_and_additionalProperties-2-filename extends_and_additionalProperties-2-ref
  ].each do |schema_name|
    test_prefix= 'test_' + schema_name.gsub('-','_')
    class_eval <<-EOB

      def #{test_prefix}_valid_outer
        assert_valid '#{schema_name}', {"outerC"=>true}, "Outer defn is broken, maybe the outer extends overrode it?"
      end

      def #{test_prefix}_valid_outer_extended
        assert_valid '#{schema_name}', {"innerA"=>true}, "Extends at the root level isn't working."
      end

      def #{test_prefix}_valid_inner
        assert_valid '#{schema_name}', {"outerB"=>[{"innerA"=>true}]}, "Extends isn't working in the array element defn."
      end

      def #{test_prefix}_invalid_inner
        refute_valid '#{schema_name}', {"outerB"=>[{"whaaaaat"=>true}]}, "Array element defn allowing anything when it should only allow what's in inner.schema"
      end
    EOB

    if schema_name['extends_and_additionalProperties-1']
      class_eval <<-EOB
        def #{test_prefix}_invalid_outer
          refute_valid '#{schema_name}', {"whaaaaat"=>true}, "Outer defn allowing anything when it shouldn't."
        end
      EOB
    end

  end
end
