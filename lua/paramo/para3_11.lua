local M = {}
local H = require("paramo/parah")
local HR = {} -- help function redefine

-- # config & setup

HR.indent = function(lnum)
	local indent = H.indent(lnum)
	if indent == -1 then
		local lnum_cursor = vim.fn.line(".")
		if H.indent(lnum_cursor) == -1 then
			indent = H.virtcol_cursor() - 1
		else
			indent = H.indent(lnum_cursor)
		end
	end
	return indent
end

-- # head & tail

M.head_p = function(lnum)
	local indent_cursor = HR.indent(vim.fn.line("."))

	if
		HR.indent(lnum) >= indent_cursor
		and
		(
			H.first_p(lnum)
			or
			HR.indent(lnum - 1) < indent_cursor
		)
	then
		return true
	else
		return false
	end
end

M.tail_p = function(lnum)
	local indent_cursor = HR.indent(vim.fn.line("."))

	if
		HR.indent(lnum) >= indent_cursor
		and
		(
			H.last_p(lnum)
			or
			HR.indent(lnum + 1) < indent_cursor
		)
	then
		return true
	else
		return false
	end
end

M.head_or_tail_p = function(lnum)
	return M.head_p(lnum) or M.tail_p(lnum)
end

-- # backward_pos & forward_pos

M.backward_pos = function(lnum, terminate_p)
	if lnum == 1 then
		return nil
	end
	if terminate_p(lnum - 1) then
		return lnum - 1
	end
	return M.backward_pos(lnum - 1, terminate_p)
end

M.forward_pos = function(lnum, terminate_p)
	if lnum == vim.fn.line("$") then
		return nil
	end
	if terminate_p(lnum + 1) then
		return lnum + 1
	end
	return M.forward_pos(lnum + 1, terminate_p)
end

-- # backward & forward

M.backward = function(terminate_p)
	local lnum0 = vim.fn.line(".")

	local lnum1 = M.backward_pos(lnum0, terminate_p)
	if lnum1 then
		H.set_cursor(lnum1, math.max(1, HR.indent(lnum1) + 1))
	end
end

M.forward = function(terminate_p)
	local lnum0 = vim.fn.line(".")

	local lnum1 = M.forward_pos(lnum0, terminate_p)
	if lnum1 then
		H.set_cursor(lnum1, math.max(1, HR.indent(lnum1) + 1))
	end
end

return M
