require 'pathname'

module JSON
  class Schema

    attr_accessor :schema, :uri, :validator
    
    def initialize(schema,uri,parent_validator=nil)
      @schema = schema
      @uri = uri
      
      # If there is an ID on this schema, use it to generate the URI
      if @schema['id']
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
    
    def validate(data, fragments, options = {})
      @validator.validate(self, data, fragments, options)
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

