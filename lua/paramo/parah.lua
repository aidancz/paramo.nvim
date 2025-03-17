-- help functions

local H = {}

H = vim.tbl_extend(
	"force",
	H,
	require("paramo/virtcol")
)

H.empty_p = function(lnum)
	return vim.fn.getline(lnum) == ""
end

H.first_p = function(lnum)
	return lnum == 1
end

H.last_p = function(lnum)
	return lnum == vim.fn.line("$")
end



H.col_first_nonblank = function(lnum)
	local line = vim.fn.getline(lnum)
	local col1, col2 = string.find(line, "%S")
	return col1
end

H.virtcol_first_nonblank = function(lnum)
	local line = vim.fn.getline(lnum)
	local col1, col2 = string.find(line, "%S")
	if col1 == nil then return nil end
	return vim.fn.virtcol({lnum, col1}, true)[1]
end

H.empty_virtcol_p = function(lnum, virtcol)
	local virtcol_max = vim.fn.virtcol({lnum, "$"})
	local virtcol_first_nonblank = H.virtcol_first_nonblank(lnum)

	if virtcol_first_nonblank == nil then
	-- empty / contain only whitespace
		return true
	end
	if virtcol < virtcol_first_nonblank then
	-- before first non-blank char
		return true
	end
	if virtcol >= virtcol_max then
	-- beyond end char
		return true
	end
	return false
end



H.eq = function(a, b)
	return a == b
end

H.gt = function(a, b)
	return a > b
end

H.lt = function(a, b)
	return a < b
end

H.neq = function(a, b)
	return not H.eq(a, b)
end

H.ngt = function(a, b)
	return not H.gt(a, b)
end

H.nlt = function(a, b)
	return not H.lt(a, b)
end

H.any = function(a, b)
	return true
end

H.indent = function(lnum)
	local virtcol_first_nonblank = H.virtcol_first_nonblank(lnum)

	local indent
	if virtcol_first_nonblank then
	-- has non-blank char
		indent = virtcol_first_nonblank - 1
	elseif H.empty_p(lnum) then
	-- empty
		indent = -1
	else
	-- only whitespace
		indent = vim.fn.virtcol({lnum, "$"}) - 1
	end

	return indent
end



H.posgetchar = function(lnum, col)
	return
	vim.fn.strpart(
		vim.fn.getline(lnum),
		col - 1,
		1,
		true
	)
end

H.first_nonblank_char = function(lnum)
	local col_first_nonblank = H.col_first_nonblank(lnum)
	if col_first_nonblank then
		return H.posgetchar(lnum, col_first_nonblank)
	else
		return nil
	end
end

return H
