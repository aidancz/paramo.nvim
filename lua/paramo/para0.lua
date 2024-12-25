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

M.backward = function()
	vim.cmd("normal! gk")
	if M.head_p() then
		return
	end
	return M.backward()
end

M.forward = function()
	vim.cmd("normal! gj")
	if M.tail_p() then
		return
	end
	return M.forward()
end

return M
