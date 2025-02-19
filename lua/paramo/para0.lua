local M = {}

M.head_p = function()
	local wininfo = vim.fn.getwininfo(vim.fn.win_getid())[1]
	local textoff = wininfo.textoff
	local width = wininfo.width
	local width_editable_text = width - textoff
	-- https://stackoverflow.com/questions/26315925/get-usable-window-width-in-vim-script
	if vim.fn.virtcol(".") <= width_editable_text then
		return true
	else
		return false
	end
end

M.tail_p = function()
	local wininfo = vim.fn.getwininfo(vim.fn.win_getid())[1]
	local textoff = wininfo.textoff
	local width = wininfo.width
	local width_editable_text = width - textoff
	if vim.fn.virtcol(".") >= vim.fn.virtcol("$") - (vim.fn.virtcol("$") % width_editable_text) + 1 then
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
