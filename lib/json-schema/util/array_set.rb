require 'set'

# This is a hack that I don't want to ever use anywhere else or repeat EVER, but we need enums to be
# an Array to pass schema validation. But we also want fast lookup!

class ArraySet < Array
  def include?(obj)
    if !defined? @values
      @values = Set.new
      self.each { |x| @values << convert_to_float_if_fixnum(x) }
    end
    @values.include?(convert_to_float_if_fixnum(obj))
  end

  private

  def convert_to_float_if_fixnum(value)
    value.is_a?(Integer) ? value.to_f : value
  end
end
