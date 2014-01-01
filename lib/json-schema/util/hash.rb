class Hash
	if !{}.respond_to?("default_proc=")
		def default_proc=(blk)
            self.replace(Hash.new(&blk).merge(self))
  		end
	end
end

