-- wrap log function in a way that we can find it easily in the log (by ModBootstrap key)
_G.LOG2 = function(a)
	LOG("ModBootstrap: ", a)
end

_G.LogTable = function(o)
	if o == nil then return LOG2("nil") end
	for k, v in o do
		LOG2(k .. " = " .. tostring(v))
	end
end
