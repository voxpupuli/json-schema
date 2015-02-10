# This is a hack that I don't want to ever use anywhere else or repeat EVER, but we need enums to be
# an Array to pass schema validation. But we also want fast lookup!

class ArraySet < Array
  def include?(obj)
    if !defined? @values
      @values = Set.new
      self.each { |x| @values << (x.is_a?(Fixnum) ? x.to_f : x) }
    end
    obj = obj.to_f if obj.is_a?(Fixnum)
    @values.include?(obj)
  end
end
