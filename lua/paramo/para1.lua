local M = {}

M.head_p = function(lnum)
	if lnum == 1 then
		return true
	end
	if vim.fn.getline(lnum) ~= "" and vim.fn.getline(lnum - 1) == "" then
		return true
	end
	return false
end

M.tail_p = function(lnum)
	if lnum == vim.fn.line("$") then
		return true
	end
	if vim.fn.getline(lnum) ~= "" and vim.fn.getline(lnum + 1) == "" then
		return true
	end
	return false
end

M.backward_lnum = function(lnum)
	if lnum == 1 then
		return lnum
	end
	if M.head_p(lnum - 1) then
		return lnum - 1
	end
	return M.backward_lnum(lnum - 1)
end

M.forward_lnum = function(lnum)
	if lnum == vim.fn.line("$") then
		return lnum
	end
	if M.tail_p(lnum + 1) then
		return lnum + 1
	end
	return M.forward_lnum(lnum + 1)
end

M.rep_call = function(func, arg, count)
	if count == 0 then
		return func(arg)
	else
		return M.rep_call(func, func(arg), (count - 1))
	end
end

M.backward = function()
	local lnum_current = vim.fn.line(".")
	local lnum_destination = M.rep_call(M.backward_lnum, lnum_current, (vim.v.count1 - 1))
	vim.cmd(tostring(lnum_destination))
end

M.forward = function()
	local lnum_current = vim.fn.line(".")
	local lnum_destination = M.rep_call(M.forward_lnum, lnum_current, (vim.v.count1 - 1))
	vim.cmd(tostring(lnum_destination))
end

return M
