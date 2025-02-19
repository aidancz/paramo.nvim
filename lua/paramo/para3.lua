local M = {}

local para_type = require("paramo/parah").type

M.head_p = function()
	local lnum = vim.fn.line(".")
	local virtcol = vim.fn.virtcol(".")
	local type = 2

	local a = para_type(lnum, virtcol) == type
	local b = lnum == 1
	local c = para_type(lnum-1, virtcol) ~= type
	if a and (b or c) then
		return true
	else
		return false
	end
end

M.tail_p = function()
	local lnum = vim.fn.line(".")
	local virtcol = vim.fn.virtcol(".")
	local type = 2

	local a = para_type(lnum, virtcol) == type
	local b = lnum == vim.fn.line("$")
	local c = para_type(lnum+1, virtcol) ~= type
	if a and (b or c) then
		return true
	else
		return false
	end
end

M.head_or_tail_p = function()
	return M.head_p() or M.tail_p()
end

M.backward = require("paramo/parah").backward
M.forward = require("paramo/parah").forward

return M
