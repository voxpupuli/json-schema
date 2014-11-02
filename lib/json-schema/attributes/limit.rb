require 'json-schema/attribute'

module JSON
  class Schema
    class LimitAttribute < Attribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        schema = current_schema.schema
        return unless data.is_a?(acceptable_type) && invalid?(schema, value(data))

        property    = build_fragment(fragments)
        description = error_message(schema)
        message = format("The property '%s' %s", property, description)
        validation_error(processor, message, fragments, current_schema, self, options[:record_errors])
      end

      def self.invalid?(schema, data)
        exclusive = exclusive?(schema)
        limit = limit(schema)

        if limit_name.start_with?('max')
          exclusive ? data >= limit : data > limit
        else
          exclusive ? data <= limit : data < limit
        end
      end

      def self.limit(schema)
        schema[limit_name]
      end

      def self.exclusive?(schema)
        false
      end

      def self.value(data)
        data
      end

      def self.acceptable_type
        raise NotImplementedError
      end

      def self.error_message(schema)
        raise NotImplementedError
      end

      def self.limit_name
        raise NotImplementedError
      end
    end

    class MinLengthAttribute < LimitAttribute
      def self.acceptable_type
        String
      end

      def self.limit_name
        'minLength'
      end

      def self.error_message(schema)
        "was not of a minimum string length of #{limit(schema)}"
      end

      def self.value(data)
        data.length
      end
    end

    class MaxLengthAttribute < MinLengthAttribute
      def self.limit_name
        'maxLength'
      end

      def self.error_message(schema)
        "was not of a maximum string length of #{limit(schema)}"
      end
    end

    class MinItemsAttribute < LimitAttribute
      def self.acceptable_type
        Array
      end

      def self.value(data)
        data.length
      end

      def self.limit_name
        'minItems'
      end

      def self.error_message(schema)
        "did not contain a minimum number of items #{limit(schema)}"
      end
    end

    class MaxItemsAttribute < MinItemsAttribute
      def self.limit_name
        'maxItems'
      end

      def self.error_message(schema)
        "had more items than the allowed #{limit(schema)}"
      end
    end

    class MinPropertiesAttribute < LimitAttribute
      def self.acceptable_type
        Hash
      end

      def self.value(data)
        data.size
      end

      def self.limit_name
        'minProperties'
      end

      def self.error_message(schema)
        "did not contain a minimum number of properties #{limit(schema)}"
      end
    end

    class MaxPropertiesAttribute < MinPropertiesAttribute
      def self.limit_name
        'maxProperties'
      end

      def self.error_message(schema)
        "had more properties than the allowed #{limit(schema)}"
      end
    end

    class NumericLimitAttribute < LimitAttribute
      def self.acceptable_type
        Numeric
      end

      def self.error_message(schema)
        exclusivity = exclusive?(schema) ? 'exclusively' : 'inclusively'
        format("did not have a %s value of %s, %s", limit_name, limit(schema), exclusivity)
      end
    end

    class MaximumAttribute < NumericLimitAttribute
      def self.limit_name
        'maximum'
      end

      def self.exclusive?(schema)
        schema['exclusiveMaximum']
      end
    end

    class MaximumInclusiveAttribute < MaximumAttribute
      def self.exclusive?(schema)
        schema['maximumCanEqual'] == false
      end
    end

    class MinimumAttribute < NumericLimitAttribute
      def self.limit_name
        'minimum'
      end

      def self.exclusive?(schema)
        schema['exclusiveMinimum']
      end
    end

    class MinimumInclusiveAttribute < MinimumAttribute
      def self.exclusive?(schema)
        schema['minimumCanEqual'] == false
      end
    end
  end
end
