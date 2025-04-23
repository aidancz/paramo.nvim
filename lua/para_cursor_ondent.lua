local H = vim.deepcopy(require("virtcol"))

H.virtcol_first_nonblank = function(lnum)
	local line = vim.fn.getline(lnum)
	local col1, col2 = string.find(line, "%S")
	if col1 == nil then return nil end
	return vim.fn.virtcol({lnum, col1}, true)[1]
end

H.indent = function(lnum)
	local virtcol_first_nonblank = H.virtcol_first_nonblank(lnum)

	local indent
	if virtcol_first_nonblank then
	-- has non-blank char
		indent = virtcol_first_nonblank - 1
	elseif vim.fn.getline(lnum) == "" then
	-- empty
		indent = -1
	else
	-- only whitespace
		indent = vim.fn.virtcol({lnum, "$"}) - 1
	end

	return indent
end

local M = {}

M.is_head = function(pos)
	local indent_cursor = H.indent(vim.fn.line("."))

	if
		(
			H.indent(pos.lnum) >= indent_cursor
		)
		and
		(
			next(H.prev_pos(pos)) == nil
			or
			H.indent(H.prev_pos(pos).lnum) < indent_cursor
		)
	then
		return true
	else
		return false
	end
end

M.is_tail = function(pos)
	local indent_cursor = H.indent(vim.fn.line("."))

	if
		(
			H.indent(pos.lnum) >= indent_cursor
		)
		and
		(
			next(H.next_pos(pos)) == nil
			or
			H.indent(H.next_pos(pos).lnum) < indent_cursor
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
