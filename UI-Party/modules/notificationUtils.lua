function getFilenameWithoutDir(filename)
	return string.gsub(filename, "[a-z]*/", "")
end


function countTableElements(t)
	local cur = 0
	for _,__ in t do
		cur = cur+1
	end
	return cur
end


function modulo(a, b)
	return a - math.floor(a/b)*b
end


function logTable(t) 
	for i, v in t do
		if(type(v) == 'table') then
			logTable(v)
		elseif(type(v) == 'boolean' or type(v) == 'bool') then
			if(v) then
				LOG(i..": true")
			else
				LOG(i..": false")
			end
		else
			LOG(i..": "..v)
		end
	end
end