local M = {}

M.head_p = function(lnum)
	lnum = lnum or vim.fn.line(".")

	if lnum == 1 then
		return true
	end
	if vim.fn.getline(lnum) ~= "" and vim.fn.getline(lnum - 1) == "" then
		return true
	end
	return false
end

M.tail_p = function(lnum)
	lnum = lnum or vim.fn.line(".")

	if lnum == vim.fn.line("$") then
		return true
	end
	if vim.fn.getline(lnum) ~= "" and vim.fn.getline(lnum + 1) == "" then
		return true
	end
	return false
end

M.head_or_tail_p = function()
	return M.head_p() or M.tail_p()
end

M.backward = require("paramo/parah").backward
M.forward = require("paramo/parah").forward

return M
