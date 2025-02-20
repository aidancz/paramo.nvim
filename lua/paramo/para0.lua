local M = {}
local H = require("paramo/parah")

M.head_p = function(lnum, col)
	lnum = lnum or vim.fn.line(".")
	col = col or vim.fn.col(".")

	local virtcol = H.virtcol(lnum, col)
	local width_editable_text = H.width_editable_text()

	if virtcol <= width_editable_text then
		return true
	else
		return false
	end
end

M.tail_p = function(lnum, col)
	lnum = lnum or vim.fn.line(".")
	col = col or vim.fn.col(".")

	local virtcol = H.virtcol(lnum, col)
	local virtcol_max = H.virtcol_max(lnum)
	local width_editable_text = H.width_editable_text()

	if virtcol >= virtcol_max - (virtcol_max % width_editable_text) + 1 then
		return true
	else
		return false
	end
end

M.head_or_tail_p = function()
	return M.head_p() or M.tail_p()
end

M.backward = function(terminate_p)
	vim.cmd("normal! gk")
	if terminate_p() then return end
	return M.backward(terminate_p)
end

M.forward = function(terminate_p)
	vim.cmd("normal! gj")
	if terminate_p() then return end
	return M.forward(terminate_p)
end

-- # help functions for other paramo:

M.ensure_head = function()
	if M.head_p() then return end
	M.backward(M.head_p)
end

return M
