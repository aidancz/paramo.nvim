local M = {}
local H = require("paramo/parah")
local HR = {} -- help function redefine

-- # config & setup

M.config = {
	indent = "eq",
--[[
	indent = "eq", -- equal indent to current
	indent = "gt", -- greater indent than current
	indent = "lt", -- less indent than current
	indent = "neq", -- not eq
	indent = "ngt", -- not gt
	indent = "nlt", -- not lt
	indent = "any", -- any indent
--]]
}

M.setup = function(config)
	M.config = vim.tbl_deep_extend("force", M.config, config or {})

	local f = load("return H." .. M.config.indent)
	setfenv(f, {H = H})
	HR.eq = f()
end

-- # head & tail

M.head_p = function(lnum)
	local indent_cursor = H.indent(vim.fn.line("."))

	if
		(
			H.first_p(lnum)
			or
			H.neq(H.indent(lnum - 1), H.indent(lnum))
		)
		and
		(
			HR.eq(H.indent(lnum), indent_cursor)
		)
	then
		return true
	else
		return false
	end
end

M.tail_p = function(lnum)
	local indent_cursor = H.indent(vim.fn.line("."))

	if
		(
			H.last_p(lnum)
			or
			H.neq(H.indent(lnum + 1), H.indent(lnum))
		)
		and
		(
			HR.eq(H.indent(lnum), indent_cursor)
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
		H.set_cursor(lnum1, math.max(1, H.indent(lnum1) + 1))
	end
end

M.forward = function(terminate_p)
	local lnum0 = vim.fn.line(".")

	local lnum1 = M.forward_pos(lnum0, terminate_p)
	if lnum1 then
		H.set_cursor(lnum1, math.max(1, H.indent(lnum1) + 1))
	end
end

return M
