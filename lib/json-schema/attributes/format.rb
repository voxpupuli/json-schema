module JSON
  class Schema
    class FormatAttribute < Attribute
      def self.validate(current_schema, data, fragments, validator, options = {})
        case current_schema.schema['format']

        # Timestamp in restricted ISO-8601 YYYY-MM-DDThh:mm:ssZ
        when 'date-time'
          error_message = "The property '#{build_fragment(fragments)}' must be a string and be a date/time in the ISO-8601 format of YYYY-MM-DDThh:mm:ssZ"
          raise ValidationError.new(error_message, fragments, current_schema) if !data.is_a?(String)
          r = Regexp.new('^\d\d\d\d-\d\d-\d\dT(\d\d):(\d\d):(\d\d)Z$')
          if (m = r.match(data))
            parts = data.split("T")
            begin
              Date.parse(parts[0])
            rescue Exception
              raise ValidationError.new(error_message, fragments, current_schema)
            end
            begin
              raise ValidationError.new(error_message, fragments, current_schema) if m[1].to_i > 23
              raise ValidationError.new(error_message, fragments, current_schema) if m[2].to_i > 59
              raise ValidationError.new(error_message, fragments, current_schema) if m[3].to_i > 59
            rescue Exception
              raise ValidationError.new(error_message, fragments, current_schema)
            end
          else
            raise ValidationError.new(error_message, fragments, current_schema)
          end

        # Date in the format of YYYY-MM-DD
        when 'date'
          error_message = "The property '#{build_fragment(fragments)}' must be a string and be a date in the format of YYYY-MM-DD"
          raise ValidationError.new(error_message, fragments, current_schema) if !data.is_a?(String)
          r = Regexp.new('^\d\d\d\d-\d\d-\d\d$')
          if (m = r.match(data))
            begin
              Date.parse(data)
            rescue Exception
              raise ValidationError.new(error_message, fragments, current_schema)
            end
          else
            raise ValidationError.new(error_message, fragments, current_schema)
          end

        # Time in the format of HH:MM:SS
        when 'time'
          error_message = "The property '#{build_fragment(fragments)}' must be a string and be a time in the format of hh:mm:ss"
          raise ValidationError.new(error_message, fragments, current_schema) if !data.is_a?(String)
          r = Regexp.new('^(\d\d):(\d\d):(\d\d)$')
          if (m = r.match(data))
            raise ValidationError.new(error_message, fragments, current_schema) if m[1].to_i > 23
            raise ValidationError.new(error_message, fragments, current_schema) if m[2].to_i > 59
            raise ValidationError.new(error_message, fragments, current_schema) if m[3].to_i > 59
          else
            raise ValidationError.new(error_message, fragments, current_schema)
          end

        # IPv4 in dotted-quad format
        when 'ip-address', 'ipv4'
          error_message = "The property '#{build_fragment(fragments)}' must be a string and be a valid IPv4 address"
          raise ValidationError.new(error_message, fragments, current_schema) if !data.is_a?(String)
          r = Regexp.new('^(\d+){1,3}\.(\d+){1,3}\.(\d+){1,3}\.(\d+){1,3}$')
          if (m = r.match(data))
            1.upto(4) do |x|
              raise ValidationError.new(error_message, fragments, current_schema) if m[x].to_i > 255
            end
          else
            raise ValidationError.new(error_message, fragments, current_schema)
          end

        # IPv6 in standard format (including abbreviations)
        when 'ipv6'
          error_message = "The property '#{build_fragment(fragments)}' must be a string and be a valid IPv6 address"
          raise ValidationError.new(error_message, fragments, current_schema) if !data.is_a?(String)
          r = Regexp.new('^[a-f0-9:]+$')
          if (m = r.match(data))
            # All characters are valid, now validate structure
            parts = data.split(":")
            raise ValidationError.new(error_message, fragments, current_schema) if parts.length > 8
            condensed_zeros = false
            parts.each do |part|
              if part.length == 0
                raise ValidationError.new(error_message, fragments, current_schema) if condensed_zeros
                condensed_zeros = true
              end
              raise ValidationError.new(error_message, fragments, current_schema) if part.length > 4
            end
          else
            raise ValidationError.new(error_message, fragments, current_schema)
          end

        # Milliseconds since the epoch. Must be an integer or a float
        when 'utc-millisec'
          error_message = "The property '#{build_fragment(fragments)}' must be an integer or a float"
          raise ValidationError.new(error_message, fragments, current_schema) if (!data.is_a?(Numeric))

        # Must be a string
        when 'regex','color','style','phone','uri','email','host-name'
          error_message = "The property '#{build_fragment(fragments)}' must be a string"
          raise ValidationError.new(error_message, fragments, current_schema) if (!data.is_a?(String))
        end
      end
    end
  end
end