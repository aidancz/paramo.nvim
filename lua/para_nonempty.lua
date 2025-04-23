local H = vim.deepcopy(require("virtcol"))

H.is_empty = function(pos)
	return vim.fn.getline(pos.lnum) == ""
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
