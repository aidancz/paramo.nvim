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
		HR.empty_virtcol_p = H.empty_virtcol_p
	else
		HR.empty_virtcol_p = function(lnum, virtcol) return not H.empty_virtcol_p(lnum, virtcol) end
	end
end

-- # head & tail

M.head_p = function(lnum, virtcol)
	local lnum_next, virtcol_next = H.backward_next(lnum, virtcol)

	if
		not HR.empty_virtcol_p(lnum, virtcol)
		and
		(
			lnum_next == nil
			or
			HR.empty_virtcol_p(lnum_next, virtcol_next)
		)
	then
		return true
	else
		return false
	end
end

M.tail_p = function(lnum, virtcol)
	local lnum_next, virtcol_next = H.forward_next(lnum, virtcol)

	if
		not HR.empty_virtcol_p(lnum, virtcol)
		and
		(
			lnum_next == nil
			or
			HR.empty_virtcol_p(lnum_next, virtcol_next)
		)
	then
		return true
	else
		return false
	end
end

M.head_or_tail_p = function(lnum, virtcol)
	return M.head_p(lnum, virtcol) or M.tail_p(lnum, virtcol)
end

-- # backward_pos & forward_pos

M.backward_pos = function(lnum, virtcol, terminate_p)
	local lnum_next, virtcol_next = H.backward_next(lnum, virtcol)

	if lnum_next == nil then
		return nil, nil
	end
	if terminate_p(lnum_next, virtcol_next) then
		return lnum_next, virtcol_next
	end
	return M.backward_pos(lnum_next, virtcol_next, terminate_p)
end

M.forward_pos = function(lnum, virtcol, terminate_p)
	local lnum_next, virtcol_next = H.forward_next(lnum, virtcol)

	if lnum_next == nil then
		return nil, nil
	end
	if terminate_p(lnum_next, virtcol_next) then
		return lnum_next, virtcol_next
	end
	return M.forward_pos(lnum_next, virtcol_next, terminate_p)
end

-- # backward & forward

M.backward = function(terminate_p)
	local lnum0 = vim.fn.line(".")
	local virtcol0 = H.virtcol_cursor()

	local lnum1, virtcol1 = M.backward_pos(lnum0, virtcol0, terminate_p)
	if lnum1 then
		H.set_cursor(lnum1, virtcol1)
		vim.cmd("normal! zv")
	end
end

M.forward = function(terminate_p)
	local lnum0 = vim.fn.line(".")
	local virtcol0 = H.virtcol_cursor()

	local lnum1, virtcol1 = M.forward_pos(lnum0, virtcol0, terminate_p)
	if lnum1 then
		H.set_cursor(lnum1, virtcol1)
		vim.cmd("normal! zv")
	end
end

return M
