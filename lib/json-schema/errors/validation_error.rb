module JSON
  class Schema
    class ValidationError < StandardError
      INDENT = "    "
      attr_accessor :fragments, :schema, :failed_attribute, :sub_errors, :message, :property

      def initialize(message, fragments, failed_attribute, schema, property = nil)
        @fragments = fragments.clone
        @property = property
        @schema = schema
        @sub_errors = {}
        @failed_attribute = failed_attribute
        @message = message
        super(message_with_schema)
      end

      def to_string(subschema_level = 0)
        if @sub_errors.empty?
          subschema_level == 0 ? message_with_schema : message
        else
          messages = ["#{message}. The schema specific errors were:\n"]
          @sub_errors.each do |subschema, errors|
            messages.push "- #{subschema}:"
            messages.concat Array(errors).map { |e| "#{INDENT}- #{e.to_string(subschema_level + 1)}" }
          end
          messages.map { |m| (INDENT * subschema_level) + m }.join("\n")
        end
      end

      def to_hash
        fragment_string = ::JSON::Schema::Attribute.build_fragment(fragments)
        if property
          property_fragments = fragments + [property]
          property_fragment_string = ::JSON::Schema::Attribute.build_fragment(property_fragments)
        else
          property_fragment_string = fragment_string
        end

        base = {
          :schema => @schema.uri,
          :fragment => fragment_string,
          :property_fragment => property_fragment_string,
          :message => message_with_schema,
          :failed_attribute => @failed_attribute.to_s.split(":").last.split("Attribute").first
        }
        if !@sub_errors.empty?
          base[:errors] = @sub_errors.inject({}) do |hsh, (subschema, errors)|
            subschema_sym = subschema.downcase.gsub(/\W+/, '_').to_sym
            hsh[subschema_sym] = Array(errors).map{|e| e.to_hash}
            hsh
          end
        end
        base
      end

      def message_with_schema
        "#{message} in schema #{schema.uri}"
      end
    end
  end
end
