require File.expand_path('../support/test_helper', __FILE__)

class ExtendsNestedTest < Minitest::Test

  def assert_validity(valid, schema_name, data, msg)
    msg = "Schema should be #{valid ? :valid : :invalid}.\n(#{schema_name}) #{msg}"
    schema = schema_fixture_path("#{schema_name}.schema.json")
    errors = JSON::Validator.fully_validate(schema, data)

    if valid
      assert_equal([], errors, msg)
    else
      refute_equal([], errors, msg)
    end
  end

  %w[
    extends_and_additionalProperties-1-filename
    extends_and_additionalProperties-1-ref
    extends_and_additionalProperties-2-filename
    extends_and_additionalProperties-2-ref
  ].each do |schema_name|
    test_prefix = 'test_' + schema_name.gsub('-','_')

    class_eval <<-EOB
      def #{test_prefix}_valid_outer
        assert_validity true, '#{schema_name}', {"outerC"=>true}, "Outer defn is broken, maybe the outer extends overrode it"
      end

      def #{test_prefix}_valid_outer_extended
        assert_validity true, '#{schema_name}', {"innerA"=>true}, "Extends at the root level isn't working"
      end

      def #{test_prefix}_valid_inner
        assert_validity true, '#{schema_name}', {"outerB"=>[{"innerA"=>true}]}, "Extends isn't working in the array element defn"
      end

      def #{test_prefix}_invalid_inner
        assert_validity false, '#{schema_name}', {"outerB"=>[{"whaaaaat"=>true}]}, "Array element defn allowing anything when it should only allow what's in inner.schema"
      end
    EOB

    if schema_name['extends_and_additionalProperties-1']
      class_eval <<-EOB
        def #{test_prefix}_invalid_outer
          assert_validity false, '#{schema_name}', {"whaaaaat"=>true}, "Outer defn allowing anything when it shouldn't"
        end
      EOB
    end

  end
end
