local H = vim.deepcopy(require("virtcol"))

H.col_first_nonblank = function(lnum)
	local line = vim.fn.getline(lnum)
	local col1, col2 = string.find(line, "%S")
	return col1
end

H.first_nonblank_char = function(lnum)
	local col_first_nonblank = H.col_first_nonblank(lnum)
	if col_first_nonblank then
		return H.posgetchar(lnum, col_first_nonblank)
	else
		return nil
	end
end

local M = {}

M.is_head = function(pos)
	if
		(
			next(H.prev_pos(pos)) == nil
			or
			H.first_nonblank_char(H.prev_pos(pos).lnum) ~= H.first_nonblank_char(pos.lnum)
		)
	then
		return true
	else
		return false
	end
end

M.is_tail = function(pos)
	if
		(
			next(H.next_pos(pos)) == nil
			or
			H.first_nonblank_char(H.next_pos(pos).lnum) ~= H.first_nonblank_char(pos.lnum)
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
