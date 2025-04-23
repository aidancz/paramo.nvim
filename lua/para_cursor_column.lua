local H = vim.deepcopy(require("virtcol"))

H.virtcol_first_nonblank = function(lnum)
	local line = vim.fn.getline(lnum)
	local col1, col2 = string.find(line, "%S")
	if col1 == nil then return nil end
	return vim.fn.virtcol({lnum, col1}, true)[1]
end

H.is_empty = function(pos)
	local virtcol_max = vim.fn.virtcol({pos.lnum, "$"})
	local virtcol_first_nonblank = H.virtcol_first_nonblank(pos.lnum)

	if virtcol_first_nonblank == nil then
	-- empty / contain only whitespace
		return true
	end
	if pos.virtcol < virtcol_first_nonblank then
	-- before first non-blank char
		return true
	end
	if pos.virtcol >= virtcol_max then
	-- beyond end char
		return true
	end
	return false
end

local M = {}

M.is_head = function(pos)
	if
		not H.is_empty(pos)
		and
		(
			next(H.prev_pos(pos)) == nil
			or
			H.is_empty(H.prev_pos(pos))
		)
	then
		return true
	else
		return false
	end
end

M.is_tail = function(pos)
	if
		not H.is_empty(pos)
		and
		(
			next(H.next_pos(pos)) == nil
			or
			H.is_empty(H.next_pos(pos))
		)
	then
		return true
	else
		return false
	end
end

M.is_head_or_tail = function(pos)
	return M.is_head(pos) or M.is_tail(pos)
end

return M
