require 'rubygems'
require 'json'
require 'pathname'

module JSON
  class Schema

    attr_accessor :schema, :uri
    
    def initialize(schema,uri)
      @schema = schema
      @uri = uri
      
      # If there is an ID on this schema, use it to generate the URI
      if @schema['id']
        temp_uri = URI.parse(@schema['id'])
        if temp_uri.relative?
          uri.path = (Pathname.new(uri.path).parent + @schema['id']).cleanpath.to_s
          temp_uri = uri
        end
        @uri = temp_uri
      end
      @uri.fragment = nil
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

