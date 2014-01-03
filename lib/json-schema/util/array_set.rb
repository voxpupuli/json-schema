# This is a hack that I don't want to ever use anywhere else or repeat EVER, but we need enums to be
# an Array to pass schema validation. But we also want fast lookup! And we can't use sets because of
# backport support... so...

class ArraySet < Array
	def include?(obj)
		# On first invocation create a HASH (yeah, yeah) to act as our set given the array values
		if !defined? @array_values
			@array_values = {}
			self.each {|x| @array_values[x] = 1}
		end
		@array_values.has_key? obj
	end
end