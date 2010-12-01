require 'uri'
require 'open-uri'
require 'pathname'
require 'bigdecimal'

module JSON
  
    class ValidationError < Exception
      attr_reader :fragments, :schema
      
      def initialize(message, fragments, schema)
        @fragments = fragments
        @schema = schema
        super(message)
      end
    end
  
    class Validator
    
    ValidationMethods = [
      "type",
      "disallow",
      "minimum",
      "maximum",
      "minItems",
      "maxItems",
      "uniqueItems",
      "pattern",
      "minLength",
      "maxLength",
      "divisibleBy",
      "enum",
      "properties",
      "patternProperties",
      "additionalProperties",
      "items",
      "additionalItems",
      "dependencies",
      "extends",
      "$ref"
    ]
    
    
    def initialize(schema_data, data)
      @schemas = {}
      @base_schema = initialize_schema(schema_data)
      @data = initialize_data(data)
      @schemas[@base_schema.uri.to_s] = @base_schema
      
      build_schemas(@base_schema)
    end  
    
    
    # Run a simple true/false validation of data against a schema
    def validate()
      begin
        validate_schema(@base_schema, @data, [])
        return true
      rescue ValidationError
        return false
      end
    end
    
    
    # Validate data against a schema, returning nil if the data is valid. If the data is invalid, 
    # a ValidationError will be raised with links to the specific location that the first error
    # occurred during validation 
    def validate2()
      validate_schema(@base_schema, @data, [])
      nil
    end
    
    
    # Validate the current schema
    def validate_schema(current_schema, data, fragments)
      
      ValidationMethods.each do |method|
        if current_schema.schema[method]
          self.send(("validate_" + method.sub('$','')).to_sym, current_schema, data, fragments)
        end
      end
      
      data
    end
    
    
    # Validate the type
    def validate_type(current_schema, data, fragments, disallow=false)
      union = true
      
      if disallow
        types = current_schema.schema['disallow']
      else
        types = current_schema.schema['type']
      end
      
      if !types.is_a?(Array)
        types = [types]
        union = false
      end
      valid = false
      
      types.each do |type|
        if type.is_a?(String)
          case type
          when "string"
            valid = data.is_a?(String)
          when "number"
            valid = data.is_a?(Numeric)
          when "integer"
            valid = data.is_a?(Integer)
          when "boolean"
            valid = (data.is_a?(TrueClass) || data.is_a?(FalseClass))
          when "object"
            valid = data.is_a?(Hash)
          when "array"
            valid = data.is_a?(Array)
          when "null"
            valid = data.is_a?(NilClass)
          when "any"
            valid = true
          else
            valid = true
          end
        elsif type.is_a?(Hash) && union
          # Validate as a schema
          schema = JSON::Schema.new(type,current_schema.uri)
          begin
            validate_schema(schema,data,fragments)
            valid = true
          rescue ValidationError
            # We don't care that these schemas don't validate - we only care that one validated
          end
        end

        break if valid
      end
      
      if (disallow)
        if valid
          message = "The property '#{build_fragment(fragments)}' matched one or more of the following types:"
          types.each {|type| message += type.is_a?(String) ? " #{type}," : " (schema)," }
          message.chop!
          raise ValidationError.new(message, fragments, current_schema)
        end
      elsif !valid
        message = "The property '#{build_fragment(fragments)}' did not match one or more of the following types:"
        types.each {|type| message += type.is_a?(String) ? " #{type}," : " (schema)," }
        message.chop!
        raise ValidationError.new(message, fragments, current_schema)
      end
    end
    
    
    # Validate the disallowed types
    def validate_disallow(current_schema, data, fragments)
      validate_type(current_schema, data, fragments, true)
    end
    
    
    # Validate the minimum value of a number
    def validate_minimum(current_schema, data, fragments)
      if data.is_a?(Numeric)
        if (current_schema.schema['exclusiveMinimum'] ? data <= current_schema.schema['minimum'] : data < current_schema.schema['minimum'])
          message = "The property '#{build_fragment(fragments)}' did not have a minimum value of #{current_schema.schema['minimum']}, "
          message += current_schema.schema['exclusiveMinimum'] ? 'exclusively' : 'inclusively'
          raise ValidationError.new(message, fragments, current_schema)
        end
      end
    end
    
    
    # Validate the maximum value of a number
    def validate_maximum(current_schema, data, fragments)
      if data.is_a?(Numeric)
        if (current_schema.schema['exclusiveMaximum'] ? data >= current_schema.schema['maximum'] : data > current_schema.schema['maximum'])
          message = "The property '#{build_fragment(fragments)}' did not have a maximum value of #{current_schema.schema['maximum']}, "
          message += current_schema.schema['exclusiveMaximum'] ? 'exclusively' : 'inclusively'
          raise ValidationError.new(message, fragments, current_schema)
        end
      end
    end
    
    
    # Validate the minimum number of items in an array
    def validate_minItems(current_schema, data, fragments)
      if data.is_a?(Array) && (data.nitems < current_schema.schema['minItems'])
        message = "The property '#{build_fragment(fragments)}' did not contain a minimum number of items #{current_schema.schema['minItems']}"
        raise ValidationError.new(message, fragments, current_schema)
      end
    end
    
    
    # Validate the maximum number of items in an array
    def validate_maxItems(current_schema, data, fragments)
      if data.is_a?(Array) && (data.nitems > current_schema.schema['maxItems'])
        message = "The property '#{build_fragment(fragments)}' did not contain a minimum number of items #{current_schema.schema['minItems']}"
        raise ValidationError.new(message, fragments, current_schema)
      end
    end
    
    
    # Validate the uniqueness of elements in an array
    def validate_uniqueItems(current_schema, data, fragments)
      if data.is_a?(Array)
        d = data.clone
        dupes = d.uniq!
        if dupes
          message = "The property '#{build_fragment(fragments)}' contained duplicated array values"
          raise ValidationError.new(message, fragments, current_schema)
        end
      end
    end
    
    
    # Validate a string matches a regex pattern
    def validate_pattern(current_schema, data, fragments)
      if data.is_a?(String)
        r = Regexp.new(current_schema.schema['pattern'])
        if (r.match(data)).nil?
          message = "The property '#{build_fragment(fragments)}' did not match the regex '#{current_schema.schema['pattern']}'"
          raise ValidationError.new(message, fragments, current_schema)
        end
      end
    end
    
    
    # Validate a string is at least of a certain length
    def validate_minLength(current_schema, data, fragments)
      if data.is_a?(String)
        if data.length < current_schema.schema['minLength']
          message = "The property '#{build_fragment(fragments)}' was not of a minimum string length of #{current_schema.schema['minLength']}"
          raise ValidationError.new(message, fragments, current_schema)
        end
      end
    end
    
    
    # Validate a string is at maximum of a certain length
    def validate_maxLength(current_schema, data, fragments)
      if data.is_a?(String)
        if data.length > current_schema.schema['maxLength']
          message = "The property '#{build_fragment(fragments)}' was not of a maximum string length of #{current_schema.schema['maxLength']}"
          raise ValidationError.new(message, fragments, current_schema)
        end
      end
    end
    
    
    # Validate a numeric is divisible by another numeric
    def validate_divisibleBy(current_schema, data, fragments)
      if data.is_a?(Numeric)
        if current_schema.schema['divisibleBy'] == 0 || 
           current_schema.schema['divisibleBy'] == 0.0 ||
           (BigDecimal.new(data.to_s) % BigDecimal.new(current_schema.schema['divisibleBy'].to_s)).to_f != 0
           message = "The property '#{build_fragment(fragments)}' was not divisible by #{current_schema.schema['divisibleBy']}"
           raise ValidationError.new(message, fragments, current_schema)
        end
      end
    end
    
    
    # Validate an item matches at least one of an array of values
    def validate_enum(current_schema, data, fragments)
      if !current_schema.schema['enum'].include?(data)
        message = "The property '#{build_fragment(fragments)}' did not match one of the following values:"
        current_schema.schema['enum'].each {|val|
          if val.is_a?(NilClass)
            message += " null,"
          elsif val.is_a?(Array)
            message += " (array),"
          elsif val.is_a?(Hash)
            message += " (object),"
          else
            message += " #{val.to_s},"
          end
        }
        message.chop!
        raise ValidationError.new(message, fragments, current_schema)
      end
    end
    
    
    # Validate a set of properties of an object
    def validate_properties(current_schema, data, fragments)
      if data.is_a?(Hash)
        current_schema.schema['properties'].each do |property,property_schema|
          if (property_schema['required'] && !data.has_key?(property))
            message = "The property '#{build_fragment(fragments)}' did not contain a required property of '#{property}'"
            raise ValidationError.new(message, fragments, current_schema)
          end
          
          if data.has_key?(property)
            schema = JSON::Schema.new(property_schema,current_schema.uri)
            fragments << property
            validate_schema(schema, data[property], fragments)
            fragments.pop
          end
        end
      end
    end
    
    
    # Validate properties of an object against a schema when the property name matches a specific regex
    def validate_patternProperties(current_schema, data, fragments)
      if data.is_a?(Hash)
        current_schema.schema['patternProperties'].each do |property,property_schema|
          r = Regexp.new(property)
          
          # Check each key in the data hash to see if it matches the regex
          data.each do |key,value|
            if r.match(key)
              schema = JSON::Schema.new(property_schema,current_schema.uri)
              fragments << key
              validate_schema(schema, data[key], fragments)
              fragments.pop
            end
          end
        end
      end
    end
    
    
    # Validate properties of an object that are not defined in the schema at least validate against a set of rules
    def validate_additionalProperties(current_schema, data, fragments)
      if data.is_a?(Hash)
        extra_properties = data.keys
        
        if current_schema.schema['properties']
          extra_properties = extra_properties - current_schema.schema['properties'].keys
        end
        
        if current_schema.schema['patternProperties']
          current_schema.schema['patternProperties'].each_key do |key|
            r = Regexp.new(key)
            extras_clone = extra_properties.clone
            extras_clone.each do |prop|
              if r.match(prop)
                extra_properties = extra_properties - [prop]
              end
            end
          end
        end
        
        if current_schema.schema['additionalProperties'] == false && !extra_properties.empty?
          message = "The property '#{build_fragment(fragments)}' contains additional properties outside of the schema when none are allowed"
          raise ValidationError.new(message, fragments, current_schema)
        elsif current_schema.schema['additionalProperties'].is_a?(Hash)
          data.each do |key,value|
            schema = JSON::Schema.new(current_schema.schema['additionalProperties'],current_schema.uri)
            fragments << key
            validate_schema(schema, value, fragments)
            fragments.pop
          end
        end
      end
    end
    
    
    # Validate items in an array match a schema or a set of schemas
    def validate_items(current_schema, data, fragments)
      if data.is_a?(Array)
         if current_schema.schema['items'].is_a?(Hash)
           data.each_with_index do |item,i|
             schema = JSON::Schema.new(current_schema.schema['items'],current_schema.uri)
             fragments << i.to_s
             validate_schema(schema,item,fragments)
             fragments.pop
           end
         elsif current_schema.schema['items'].is_a?(Array)
           current_schema.schema['items'].each_with_index do |item_schema,i|
             schema = JSON::Schema.new(item_schema,current_schema.uri)
             fragments << i.to_s
             validate_schema(schema,data[i],fragments)
             fragments.pop
           end
         end
      end
    end
    
    
    # Validate items in an array that are not part of the schema at least match a set of rules
    def validate_additionalItems(current_schema, data, fragments)
      if data.is_a?(Array) && current_schema.schema['items'].is_a?(Array)
        if current_schema.schema['additionalItems'] == false && current_schema.schema['items'].length != data.length
          message = "The property '#{build_fragment(fragments)}' contains additional array elements outside of the schema when none are allowed"
          raise ValidationError.new(message, fragments, current_schema)
        elsif current_schema.schema['additionaItems'].is_a?(Hash)
          schema = JSON::Schema.new(current_schema.schema['additionalItems'],current_schema.uri)
          data.each_with_index do |item,i|
            if i >= current_schema.schema['items'].length
              fragments << i.to_s
              validate_schema(schema, item, fragments)
              fragments.pop
            end
          end
        end
      end
    end
    
    
    # Validate the dependencies of a property
    def validate_dependencies(current_schema, data, fragments)
      if data.is_a?(Hash)
        current_schema.schema['dependencies'].each do |property,dependency_value|
          if data.has_key?(property)
            if dependency_value.is_a?(String) && !data.has_key?(dependency_value)
              message = "The property '#{build_fragment(fragments)}' has a property '#{property}' that depends on a missing property '#{dependency_value}'"
              raise ValidationError.new(message, fragments, current_schema)
            elsif dependency_value.is_a?(Array)
              dependency_value.each do |value|
                if !data.has_key?(value)
                  message = "The property '#{build_fragment(fragments)}' has a property '#{property}' that depends on a missing property '#{value}'"
                  raise ValidationError.new(message, fragments, current_schema)
                end
              end
            else
              schema = JSON::Schema.new(dependency_value,current_schema.uri)
              validate_schema(schema, data, fragments)
            end
          end
        end
      end
    end
    
    
    # Validate extensions of other schemas
    def validate_extends(current_schema, data, fragments)
      schemas = current_schema.schema['extends']
      schemas = [schemas] if !schemas.is_a?(Array)
      schemas.each do |s|
        schema = JSON::Schema.new(s,current_schema.uri)
        validate_schema(schema, data, fragments)
      end
    end
    
    
    # Validate schema references
    def validate_ref(current_schema, data, fragments)
      temp_uri = URI.parse(current_schema.schema['$ref'])
      if temp_uri.relative?
        temp_uri = current_schema.uri.clone
        # Check for absolute path
        path = current_schema.schema['$ref'].split("#")[0]
        if path[0,1] == "/"
          temp_uri.path = Pathname.new(path).cleanpath
        else
          temp_uri.path = (Pathname.new(current_schema.uri.path).parent + path).cleanpath
        end
        temp_uri.fragment = current_schema.schema['$ref'].split("#")[1]
      end
      temp_uri.fragment = "" if temp_uri.fragment.nil?
      
      # Grab the parent schema from the schema list
      schema_key = temp_uri.to_s.split("#")[0]
      ref_schema = @schemas[schema_key]
      
      if ref_schema
        # Perform fragment resolution to retrieve the appropriate level for the schema
        target_schema = ref_schema.schema
        fragments = temp_uri.fragment.split("/")
        fragments.each do |fragment|
          if fragment && fragment != ''
            if target_schema.is_a?(Array)
              target_schema = target_schema[fragment.to_i]
            else
              target_schema = target_schema[fragment]
            end
          end
        end
        
        # We have the schema finally, build it and validate!
        schema = JSON::Schema.new(target_schema,temp_uri)
        validate_schema(schema, data, fragments)
      end
    end
    

    def build_fragment(fragments)
      "#/#{fragments.join('/')}"
    end

    
    def load_ref_schema(parent_schema,ref)
      uri = URI.parse(ref)
      if uri.relative?
        uri = parent_schema.uri.clone
        # Check for absolute path
        path = ref.split("#")[0]
        if path[0,1] == '/'
          uri.path = Pathname.new(path).cleanpath
        else
          uri.path = (Pathname.new(parent_schema.uri.path).parent + path).cleanpath
        end
        uri.fragment = nil
      end
      
      if @schemas[uri.to_s].nil?
        begin
          schema = JSON::Schema.new(JSON.parse(open(uri.to_s).read), uri)
          @schemas[uri.to_s] = schema
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
      if parent_schema.schema["type"] && parent_schema.schema["type"].is_a?(Array) # If we're dealing with a Union type, there might be schemas a-brewin'
        parent_schema.schema["type"].each_with_index do |type,i|
          if type.is_a?(Hash) 
            if type['$ref']
              load_ref_schema(parent_schema, type['$ref'])
            else
              schema_uri = parent_schema.uri.clone
              schema = JSON::Schema.new(type,schema_uri)
              if type['id']
                @schemas[schema.uri.to_s] = schema
              end
              build_schemas(schema)
            end
          end
        end
      end
      
      if parent_schema.schema["disallow"] && parent_schema.schema["disallow"].is_a?(Array) # If we're dealing with a Union type, there might be schemas a-brewin'
        parent_schema.schema["disallow"].each_with_index do |type,i|
          if type.is_a?(Hash)
            if type['$ref']
              load_ref_schema(parent_schema, type['$ref'])
            else
              type['id']
              schema_uri = parent_schema.uri.clone
              schema = JSON::Schema.new(type,schema_uri)
              if type['id']
                @schemas[schema.uri.to_s] = schema
              end
              build_schemas(schema)
            end
          end
        end
      end
        
      if parent_schema.schema["properties"]
        parent_schema.schema["properties"].each do |k,v|
          if v['$ref']
            load_ref_schema(parent_schema, v['$ref'])
          else
            schema_uri = parent_schema.uri.clone
            schema = JSON::Schema.new(v,schema_uri)
            if v['id']
              @schemas[schema.uri.to_s] = schema
            end
            build_schemas(schema)
          end
        end
      end
      
      if parent_schema.schema["additionalProperties"].is_a?(Hash) 
        if parent_schema.schema["additionalProperties"]["$ref"]
          load_ref_schema(parent_schema, parent_schema.schema["additionalProperties"]["$ref"])
        else
          schema_uri = parent_schema.uri.clone
          schema = JSON::Schema.new(parent_schema.schema["additionalProperties"],schema_uri)
          if parent_schema.schema["additionalProperties"]['id']
            @schemas[schema.uri.to_s] = schema
          end
          build_schemas(schema)
        end
      end
      
      if parent_schema.schema["items"]
        items = parent_schema.schema["items"].clone
        single = false
        if !items.is_a?(Array)
          items = [items]
          single = true
        end
        items.each_with_index do |item,i|
          if item['$ref']
            load_ref_schema(parent_schema, item['$ref'])
          else
            schema_uri = parent_schema.uri.clone
            schema = JSON::Schema.new(item,schema_uri)
            if item['id']
              @schemas[schema.uri.to_s] = schema
            end
            build_schemas(schema)
          end
        end
      end
      
      if parent_schema.schema["additionalItems"].is_a?(Hash)
        if parent_schema.schema["additionalItems"]['$ref']
          load_ref_schema(parent_schema, parent_schema.schema["additionalItems"]['$ref'])
        else
          schema_uri = parent_schema.uri.clone
          schema = JSON::Schema.new(parent_schema.schema["additionalItems"],schema_uri)
          if parent_schema.schema["additionalItems"]['id']
            @schemas[schema.uri.to_s] = schema
          end
          build_schemas(schema)
        end
      end
      
      if parent_schema.schema["dependencies"].is_a?(Hash)
        if parent_schema.schema["dependencies"]["$ref"]
          load_ref_schema(parent_schema, parent_schema.schema["dependencies"]['$ref'])
        else
          schema_uri = parent_schema.uri.clone
          schema = JSON::Schema.new(parent_schema.schema["dependencies"],schema_uri)
          if parent_schema.schema["dependencies"]['id']
            @schemas[schema.uri.to_s] = schema
          end
          build_schemas(schema)
        end
      end
      
      if parent_schema.schema["extends"].is_a?(Hash)
        if parent_schema.schema["extends"]['$ref']
          load_ref_schema(parent_schema, parent_schema.schema["extends"]['$ref'])
        else
          schema_uri = parent_schema.uri.clone
          schema = JSON::Schema.new(parent_schema.schema["extends"],schema_uri)
          if parent_schema.schema["extends"]['id']
            @schemas[schema.uri.to_s] = schema
          end
          build_schemas(schema)
        end
      end
    end
        
    
    class << self
      def validate(schema, data)
        validator = JSON::Validator.new(schema, data)
        validator.validate
      end
    
      def validate2(schema, data)
        validator = JSON::Validator.new(schema, data)
        validator.validate2
      end
    end
  
    
    
    private
    
    def initialize_schema(schema)
      schema_uri = URI.parse("file://#{Dir.pwd}/__base_schema__.json")
      if schema.is_a?(String)
        begin
          schema = JSON.parse(schema)
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
          schema = JSON.parse(open(schema_uri.to_s).read)
        end
      end
      
      JSON::Schema.new(schema,schema_uri)
    end
    
    
    def initialize_data(data)
      # Parse the data, if any
      if data.is_a?(String)
        begin
          data = JSON.parse(data)
        rescue
          json_uri = URI.parse(data)
          if json_uri.relative?
            if data[0,1] == '/'
              schema_uri = URI.parse("file://#{data}")
            else
              schema_uri = URI.parse("file://#{Dir.pwd}/#{data}")
            end
          end
          data = JSON.parse(open(json_uri.to_s).read)
        end
      end
      data
    end
    
  end
end