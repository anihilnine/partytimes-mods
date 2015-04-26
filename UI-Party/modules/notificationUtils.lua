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