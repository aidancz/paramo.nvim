local M = {}
local H = require("paramo/parah")
local HR = {} -- help function redefine

-- # config & setup

M.config = {
	indent = "eq",
--[[
	indent = "eq",
	-- equal indent to current
	indent = "neq",
	-- not equal indent to current
	indent = "gt",
	-- greater indent than current
	indent = "lt",
	-- less indent than current
	indent = "any",
	-- any indent
--]]
	include_more_indent = false,
	include_empty = false,
}

M.setup = function(config)
	M.config = vim.tbl_deep_extend("force", M.config, config or {})

	if	M.config.indent == "eq"		then	HR.eq = H.eq
	elseif	M.config.indent == "neq"	then	HR.eq = H.neq
	elseif	M.config.indent == "gt"		then	HR.eq = H.gt
	elseif	M.config.indent == "lt"		then	HR.eq = H.lt
	elseif	M.config.indent == "any"	then	HR.eq = H.any
	end
	if not M.config.include_more_indent then
		HR.neq = H.neq
	else
		HR.neq = H.lt
	end
	if not M.config.include_empty then
		HR.indent = H.indent
	else
		HR.indent = function(lnum)
			local indent = H.indent(lnum)
			if indent == -1 then
				indent = H.indent(vim.fn.line("."))
			end
			return indent
		end
	end
end

-- # head & tail

M.head_p = function(lnum)
	local indent = HR.indent(vim.fn.line("."))

	if
		HR.eq(HR.indent(lnum), indent)
		and
		(
			H.first_p(lnum)
			or
			HR.neq(HR.indent(lnum - 1), HR.indent(lnum))
		)
	then
		return true
	else
		return false
	end
end

M.tail_p = function(lnum)
	local indent = HR.indent(vim.fn.line("."))

	if
		HR.eq(HR.indent(lnum), indent)
		and
		(
			H.last_p(lnum)
			or
			HR.neq(HR.indent(lnum + 1), HR.indent(lnum))
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
	if lnum == 0 then
		return nil
	end
	if terminate_p(lnum - 1) then
		return lnum - 1
	end
	return M.backward_pos(lnum - 1, terminate_p)
end

M.forward_pos = function(lnum, terminate_p)
	if lnum == vim.fn.line("$") + 1 then
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
