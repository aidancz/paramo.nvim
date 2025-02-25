local M = {}
local H = require("paramo/parah")

-- # config & setup

-- # head & tail

M.head_p = function(lnum, virtcol)
	local width_editable_text = H.width_editable_text()

	if virtcol <= width_editable_text then
		return true
	else
		return false
	end
end

M.tail_p = function(lnum, virtcol)
	local virtcol_max_real = H.virtcol_max_real(lnum)
	local width_editable_text = H.width_editable_text()

	if virtcol >= virtcol_max_real - (virtcol_max_real % width_editable_text) + 1 then
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
	end
end

M.forward = function(terminate_p)
	local lnum0 = vim.fn.line(".")
	local virtcol0 = H.virtcol_cursor()

	local lnum1, virtcol1 = M.forward_pos(lnum0, virtcol0, terminate_p)
	if lnum1 then
		H.set_cursor(lnum1, virtcol1)
	end
end

-- # help functions for other paramo:

M.ensure_head = function()
	local lnum0 = vim.fn.line(".")
	local virtcol0 = H.virtcol_cursor()

	if M.head_p(lnum0, virtcol0) then return end
	M.backward(M.head_p)
end

return M
