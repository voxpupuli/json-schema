module JSON
  class Schema
    class ValidationError < StandardError
      attr_accessor :fragments, :schema, :failed_attribute, :sub_errors

      def initialize(message, fragments, failed_attribute, schema)
        @fragments = fragments.clone
        @schema = schema
        @sub_errors = []
        @failed_attribute = failed_attribute
        message = "#{message} in schema #{schema.uri}"
        super(message)
      end

      def to_string
        if @sub_errors.empty?
          message
        else
          full_message = message + "\n The schema specific errors were:\n"
          @sub_errors.each{|e| full_message = full_message + " - " + e.to_string + "\n"}
          full_message
        end
      end

      def to_hash
        base = {:schema => @schema.uri, :fragment => ::JSON::Schema::Attribute.build_fragment(fragments), :message => message, :failed_attribute => @failed_attribute.to_s.split(":").last.split("Attribute").first}
        if !@sub_errors.empty?
          base[:errors] = @sub_errors.map{|e| e.to_hash}
        end
        base
      end
    end
  end
end
