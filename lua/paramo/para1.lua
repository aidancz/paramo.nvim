local M = {}
local H = require("paramo/parah")
local HR = {} -- help function redefine

-- # config & setup

M.config = {
	empty = false,
}

M.setup = function(config)
	M.config = vim.tbl_deep_extend("force", M.config, config or {})

	if not M.config.empty then
		HR.empty_p = H.empty_p
	else
		HR.empty_p = function(lnum) return not H.empty_p(lnum) end
	end
end

-- # head & tail

M.head_p = function(lnum)
	if
		not HR.empty_p(lnum)
		and
		(
			H.first_p(lnum)
			or
			HR.empty_p(lnum - 1)
		)
	then
		return true
	else
		return false
	end
end

M.tail_p = function(lnum)
	if
		not HR.empty_p(lnum)
		and
		(
			H.last_p(lnum)
			or
			HR.empty_p(lnum + 1)
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
		require("paramo/para0").ensure_head()
		vim.cmd(tostring(lnum1))
		vim.cmd("normal! zv")
	end
end

M.forward = function(terminate_p)
	local lnum0 = vim.fn.line(".")

	local lnum1 = M.forward_pos(lnum0, terminate_p)
	if lnum1 then
		require("paramo/para0").ensure_head()
		vim.cmd(tostring(lnum1))
		vim.cmd("normal! zv")
	end
end

return M
