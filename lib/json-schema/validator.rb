require 'uri'
require 'open-uri'
require 'pathname'
require 'bigdecimal'
require 'digest/sha1'
require 'date'

module JSON
  
  class Schema
    class ValidationError < Exception
      attr_reader :fragments, :schema

      def initialize(message, fragments, schema)
        @fragments = fragments
        @schema = schema
        message = "#{message} in schema #{schema.uri}"
        super(message)
      end
    end
    
    class SchemaError < Exception
    end
    
    class JsonParseError < Exception
    end
    
    class Attribute
      def self.validate(current_schema, data, fragments, validator, options = {})
      end
      
      def self.build_fragment(fragments)
        "#/#{fragments.join('/')}"
      end
    end
    
    class Validator
      attr_accessor :attributes, :uri
      
      def initialize()
        @attributes = {}
        @uri = nil
      end
      
      def extend_schema_definition(schema_uri)
        u = URI.parse(schema_uri)
        validator = JSON::Validator.validators["#{u.scheme}://#{u.host}#{u.path}"]
        if validator.nil?
          raise SchemaError.new("Schema not found: #{u.scheme}://#{u.host}#{u.path}")
        end
        @attributes.merge!(validator.attributes)
      end
      
      def to_s
        "#{@uri.scheme}://#{uri.host}#{uri.path}"
      end
      
      def validate(current_schema, data, fragments)
        current_schema.schema.each do |attr_name,attribute|
          
          if @attributes.has_key?(attr_name.to_s)
            @attributes[attr_name.to_s].validate(current_schema, data, fragments, self)
          end
        end
        data
      end
    end
  end
  

  class Validator

    @@schemas = {}
    @@cache_schemas = false
    @@default_opts = {
      :list => false
    }
    @@validators = {}
    @@default_validator = nil
    @@available_json_backends = []
    @@json_backend = nil
    
    def initialize(schema_data, data, opts={})
      @options = @@default_opts.clone.merge(opts)
      @base_schema = initialize_schema(schema_data)
      @data = initialize_data(data)    
      build_schemas(@base_schema)
    end  
    
    
    # Run a simple true/false validation of data against a schema
    def validate()
      begin
        @base_schema.validate(@data,[])
        Validator.clear_cache
      rescue JSON::Schema::ValidationError
        Validator.clear_cache
        raise $!
      end
    end

    
    def load_ref_schema(parent_schema,ref)
      uri = URI.parse(ref)
      if uri.relative?
        uri = parent_schema.uri.clone
        
        # Check for absolute path
        path = ref.split("#")[0]
        
        # This is a self reference and thus the schema does not need to be re-loaded
        if path.nil? || path == ''
          return
        end
        
        if path && path[0,1] == '/'
          uri.path = Pathname.new(path).cleanpath.to_s
        else
          uri.path = (Pathname.new(parent_schema.uri.path).parent + path).cleanpath.to_s
        end
        uri.fragment = nil
      end
      
      if Validator.schemas[uri.to_s].nil?
        begin
          schema = JSON::Schema.new(JSON::Validator.parse(open(uri.to_s).read), uri)
          Validator.add_schema(schema)
          build_schemas(schema)
        rescue JSON::ParserError
          # Don't rescue this error, we want JSON formatting issues to bubble up
          raise $!
        rescue
          # Failures will occur when this URI cannot be referenced yet. Don't worry about it,
          # the proper error will fall out if the ref isn't ever defined
        end
      end
    end
    
    
    # Build all schemas with IDs, mapping out the namespace
    def build_schemas(parent_schema)    
      # Check for schemas in union types
      ["type", "disallow"].each do |key|
        if parent_schema.schema[key] && parent_schema.schema[key].is_a?(Array)
          parent_schema.schema[key].each_with_index do |type,i|
            if type.is_a?(Hash) 
              handle_schema(parent_schema, type)
            end
          end
        end
      end
        
      # All properties are schemas
      if parent_schema.schema["properties"]
        parent_schema.schema["properties"].each do |k,v|
          handle_schema(parent_schema, v)
        end
      end
      
      # Items are always schemas
      if parent_schema.schema["items"]
        items = parent_schema.schema["items"].clone
        single = false
        if !items.is_a?(Array)
          items = [items]
          single = true
        end
        items.each_with_index do |item,i|
          handle_schema(parent_schema, item)
        end
      end
      
      # Each of these might be schemas
      ["additionalProperties", "additionalItems", "dependencies", "extends"].each do |key|
        if parent_schema.schema[key].is_a?(Hash) 
          handle_schema(parent_schema, parent_schema.schema[key])
        end
      end
      
    end
    
    # Either load a reference schema or create a new schema
    def handle_schema(parent_schema, obj)
      if obj['$ref']
         load_ref_schema(parent_schema, obj['$ref'])
       else
         schema_uri = parent_schema.uri.clone
         schema = JSON::Schema.new(obj,schema_uri)
         if obj['id']
           Validator.add_schema(schema)
         end
         build_schemas(schema)
       end
    end
        
    
    class << self
      def validate(schema, data,opts={})
        begin
          validator = JSON::Validator.new(schema, data, opts)
          validator.validate
          return true
        rescue JSON::Schema::ValidationError, JSON::Schema::SchemaError
          return false
        end
      end
    
      def validate!(schema, data,opts={})
        validator = JSON::Validator.new(schema, data, opts)
        validator.validate
      end
      alias_method 'validate2', 'validate!'
      
      def clear_cache
        @@schemas = {} if @@cache_schemas == false
      end
      
      def schemas
        @@schemas
      end
      
      def add_schema(schema)
        @@schemas[schema.uri.to_s] = schema if @@schemas[schema.uri.to_s].nil?
      end
      
      def cache_schemas=(val)
        @@cache_schemas = val == true ? true : false
      end
      
      def validators
        @@validators
      end
      
      def default_validator
        @@default_validator
      end
      
      def register_validator(v)
        @@validators[v.to_s] = v
      end
      
      def register_default_validator(v)
        @@default_validator = v
      end
      
      def json_backend
        @@json_backend
      end
      
      def json_backend=(backend)
        backend = backend.to_s
        if @@available_json_backend.include?(backend)
          @@json_backend = backend
        else
          raise JSON::Schema::JsonParseError.new("The JSON backend '#{backend}' could not be found.")
        end
      end
      
      def parse(s)
        case @@json_backend.to_s
        when 'json'
          JSON.parse(s)
        when 'yajl'
          json = StringIO.new(s)
          parser = Yajl::Parser.new
          parser.parse(json)
        else
          raise JSON::Schema::JsonParseError.new("No supported JSON parsers found. The following parsers are suported:\n * yajl-ruby\n * json")
        end
      end
    end
  
    if Gem.available?('json')
      require 'json'
      @@available_json_backends << 'json'
      @@json_backend = 'json'
    end
    
    if Gem.available?('yajl-ruby')
      require 'yajl'
      @@available_json_backends << 'yajl'
      @@json_backend = 'yajl'
    end
    
    
    private
    
    def initialize_schema(schema)
      if schema.is_a?(String)
        begin
          # Build a fake URI for this
          schema_uri = URI.parse(UUID.create_v5(schema,UUID::Nil).to_s)
          schema = JSON::Validator.parse(schema)
          if @options[:list]
            schema = {"type" => "array", "items" => schema}
          end
          schema = JSON::Schema.new(schema,schema_uri)
          Validator.add_schema(schema)
        rescue
          # Build a uri for it
          schema_uri = URI.parse(schema)
          if schema_uri.relative?
            # Check for absolute path
            if schema[0,1] == '/'
              schema_uri = URI.parse("file://#{schema}")
            else
              schema_uri = URI.parse("file://#{Dir.pwd}/#{schema}")
            end
          end
          if Validator.schemas[schema_uri.to_s].nil?
            schema = JSON::Validator.parse(open(schema_uri.to_s).read)
            if @options[:list]
              schema = {"type" => "array", "items" => schema}
            end
            schema = JSON::Schema.new(schema,schema_uri)
            Validator.add_schema(schema)
          else
            schema = Validator.schemas[schema_uri.to_s]
          end
        end
      elsif schema.is_a?(Hash)
        if @options[:list]
          schema = {"type" => "array", "items" => schema}
        end
        schema_uri = URI.parse(UUID.create_v5(schema.inspect,UUID::Nil).to_s)
        schema = JSON::Schema.new(schema,schema_uri)
        Validator.add_schema(schema)
      else
        raise "Invalid schema - must be either a string or a hash"
      end   
      
      schema
    end
    
    
    def initialize_data(data)
      # Parse the data, if any
      if data.is_a?(String)
        begin
          data = JSON::Validator.parse(data)
        rescue
          json_uri = URI.parse(data)
          if json_uri.relative?
            if data[0,1] == '/'
              schema_uri = URI.parse("file://#{data}")
            else
              schema_uri = URI.parse("file://#{Dir.pwd}/#{data}")
            end
          end
          data = JSON::Validator.parse(open(json_uri.to_s).read)
        end
      end
      data
    end
    
  end
end