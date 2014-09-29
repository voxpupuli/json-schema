require 'pathname'
require 'json-schema/errors/schema_error'

module JSON
  class Schema

    attr_accessor :schema, :uri, :validator

    def initialize(schema,uri,parent_validator=nil)
      @schema = schema
      @uri = uri

      self.class.add_indifferent_access(@schema)

      # If there is an ID on this schema, use it to generate the URI
      if @schema['id'] && @schema['id'].kind_of?(String)
        temp_uri = URI.parse(@schema['id'])
        if temp_uri.relative?
          uri = uri.merge(@schema['id'])
          temp_uri = uri
        end
        @uri = temp_uri
      end
      @uri.fragment = ''

      # If there is a $schema on this schema, use it to determine which validator to use
      if @schema['$schema']
        u = URI.parse(@schema['$schema'])
        @validator = JSON::Validator.validators["#{u.scheme}://#{u.host}#{u.path}"]
        if @validator.nil?
          raise SchemaError.new("This library does not have support for schemas defined by #{u.scheme}://#{u.host}#{u.path}")
        end
      elsif parent_validator
        @validator = parent_validator
      else
        @validator = JSON::Validator.default_validator
      end
    end

    def validate(data, fragments, processor, options = {})
      @validator.validate(self, data, fragments, processor, options)
    end

    def self.add_indifferent_access(schema)
      if schema.is_a?(Hash)
        schema.default_proc = proc do |hash,key|
          if hash.has_key?(key)
            hash[key]
          else
            key = case key
            when Symbol then key.to_s
            when String then key.to_sym
            end
            hash.has_key?(key) ? hash[key] : nil
          end
        end
        schema.keys.each do |key|
          add_indifferent_access(schema[key])
        end
      elsif schema.is_a?(Array)
        schema.each do |schema_item|
          add_indifferent_access(schema_item)
        end
      end
    end

    def base_uri
      parts = @uri.to_s.split('/')
      parts.pop
      parts.join('/') + '/'
    end

    def to_s
      @schema.to_json
    end
  end
end

