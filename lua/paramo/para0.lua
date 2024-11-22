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

M.backward_one = function()
	vim.cmd("normal! gk")
	if M.head_p() then
		return
	end
	return M.backward()
end

M.forward_one = function()
	vim.cmd("normal! gj")
	if M.tail_p() then
		return
	end
	return M.forward()
end

M.mul_call = function(func, count)
	for i = 1, count do
		func()
	end
end

M.backward = function()
	M.mul_call(M.backward_one, vim.v.count1)
end

M.forward = function()
	M.mul_call(M.forward_one, vim.v.count1)
end



return M
