_G.from = function(t)
	local self = {}
	
	self.t = t
	
	self.select = function(p) 
		local result = {}
		for k,v in self.t do
			if p(k,v) then
				result[k] = p(k,v)
			end
		end
		return from(result)
	end
	
	self.where = function(p)
		local result = {}
		for k,v in self.t do
			if p(k,v) then
				result[k] = v
			end
		end
		return from(result)
	end
	
	self.first = function(condition)
		for k,v in self.t do
			if not condition or condition(k,v) then return v end
		end
		return nil
	end

	self.any = function(condition)
		for k,v in self.t do
			if not condition or condition(k,v) then return true
		end
		return false
	end
	
	self.toArray = function()
		local result = {}
		for k,v in self.t do
			table.insert(result, v)
		end
		return result
	end
	
	self.toDictionary = function() 
		return t
	end

	return self
end