module JSON
  class Schema
    class FormatAttribute < Attribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        case current_schema.schema['format']

        # Timestamp in restricted ISO-8601 YYYY-MM-DDThh:mm:ssZ with optional decimal fraction of the second
        when 'date-time'
          error_message = "The property '#{build_fragment(fragments)}' must be a date/time in the ISO-8601 format of YYYY-MM-DDThh:mm:ssZ or YYYY-MM-DDThh:mm:ss.ssZ"
          validation_error(processor, error_message, fragments, current_schema, self, options[:record_errors]) and return if !data.is_a?(String)
          r = Regexp.new('^\d\d\d\d-\d\d-\d\dT(\d\d):(\d\d):(\d\d)([\.,]\d+)?(Z|[+-](\d\d)(:\d\d)?)?$')
          if (m = r.match(data))
            parts = data.split("T")
            begin
              Date.parse(parts[0])
            rescue Exception
              validation_error(processor, error_message, fragments, current_schema, self, options[:record_errors])
              return
            end
            begin
              validation_error(processor, error_message, fragments, current_schema, self, options[:record_errors]) and return if m[1].to_i > 23
              validation_error(processor, error_message, fragments, current_schema, self, options[:record_errors]) and return if m[2].to_i > 59
              validation_error(processor, error_message, fragments, current_schema, self, options[:record_errors]) and return if m[3].to_i > 59
            rescue Exception
              validation_error(processor, error_message, fragments, current_schema, self, options[:record_errors])
              return
            end
          else
            validation_error(processor, error_message, fragments, current_schema, self, options[:record_errors])
            return
          end

        # Date in the format of YYYY-MM-DD
        when 'date'
          error_message = "The property '#{build_fragment(fragments)}' must be a date in the format of YYYY-MM-DD"
          validation_error(processor, error_message, fragments, current_schema, self, options[:record_errors]) and return if !data.is_a?(String)
          r = Regexp.new('^\d\d\d\d-\d\d-\d\d$')
          if (m = r.match(data))
            begin
              Date.parse(data)
            rescue Exception
              validation_error(processor, error_message, fragments, current_schema, self, options[:record_errors])
              return
            end
          else
            validation_error(processor, error_message, fragments, current_schema, self, options[:record_errors])
            return
          end

        # Time in the format of HH:MM:SS
        when 'time'
          error_message = "The property '#{build_fragment(fragments)}' must be a time in the format of hh:mm:ss"
          validation_error(processor, error_message, fragments, current_schema, self, options[:record_errors]) and return if !data.is_a?(String)
          r = Regexp.new('^(\d\d):(\d\d):(\d\d)$')
          if (m = r.match(data))
            validation_error(processor, error_message, fragments, current_schema, self, options[:record_errors]) and return if m[1].to_i > 23
            validation_error(processor, error_message, fragments, current_schema, self, options[:record_errors]) and return if m[2].to_i > 59
            validation_error(processor, error_message, fragments, current_schema, self, options[:record_errors]) and return if m[3].to_i > 59
          else
            validation_error(processor, error_message, fragments, current_schema, self, options[:record_errors])
            return
          end

        # IPv4 in dotted-quad format
        when 'ip-address', 'ipv4'
          error_message = "The property '#{build_fragment(fragments)}' must be a valid IPv4 address"
          validation_error(processor, error_message, fragments, current_schema, self, options[:record_errors]) and return if !data.is_a?(String)
          r = Regexp.new('^(\d+){1,3}\.(\d+){1,3}\.(\d+){1,3}\.(\d+){1,3}$')
          if (m = r.match(data))
            1.upto(4) do |x|
              validation_error(processor, error_message, fragments, current_schema, self, options[:record_errors]) and return if m[x].to_i > 255
            end
          else
            validation_error(processor, error_message, fragments, current_schema, self, options[:record_errors])
            return
          end

        # IPv6 in standard format (including abbreviations)
        when 'ipv6'
          error_message = "The property '#{build_fragment(fragments)}' must be a valid IPv6 address"
          validation_error(processor, error_message, fragments, current_schema, self, options[:record_errors]) and return if !data.is_a?(String)
          r = Regexp.new('^[a-f0-9:]+$')
          if (m = r.match(data))
            # All characters are valid, now validate structure
            parts = data.split(":")
            validation_error(processor, error_message, fragments, current_schema, self, options[:record_errors]) and return if parts.length > 8
            condensed_zeros = false
            parts.each do |part|
              if part.length == 0
                validation_error(processor, error_message, fragments, current_schema, self, options[:record_errors]) and return if condensed_zeros
                condensed_zeros = true
              end
              validation_error(processor, error_message, fragments, current_schema, self, options[:record_errors]) and return if part.length > 4
            end
          else
            validation_error(processor, error_message, fragments, current_schema, self, options[:record_errors])
            return
          end
        end
      end
    end
  end
end
