local M = {}

local PARA2_TYPE0 = 0
-- empty line
local PARA2_TYPE1 = 1
-- before first non-blank char
local PARA2_TYPE2 = 2
-- first non-blank char to end char
local PARA2_TYPE3 = 3
-- beyond end char



M.type = function(lnum, virtcol)
	local virtcol_max = vim.fn.virtcol({lnum, "$"})

	if virtcol_max == 1 then
		return PARA2_TYPE0
	elseif virtcol >= virtcol_max then
		return PARA2_TYPE3
	else
		local col = vim.fn.virtcol2col(0, lnum, virtcol)
		local char = vim.api.nvim_buf_get_text(0, lnum-1, col-1, lnum-1, col-1+1, {})[1]
		local prestr = vim.api.nvim_buf_get_text(0, lnum-1, 0, lnum-1, col-1+1, {})[1]

		if (char == " " or char == "\t") and prestr:match("^%s+$") ~= nil then
			return PARA2_TYPE1
		else
			return PARA2_TYPE2
		end
	end
end

M.head_p = function(lnum, virtcol, type)
	local a = M.type(lnum, virtcol) == type
	local b = lnum == 1
	local c = M.type(lnum-1, virtcol) ~= type
	if a and (b or c) then
		return true
	else
		return false
	end
end

M.tail_p = function(lnum, virtcol, type)
	local a = M.type(lnum, virtcol) == type
	local b = lnum == vim.fn.line("$")
	local c = M.type(lnum+1, virtcol) ~= type
	if a and (b or c) then
		return true
	else
		return false
	end
end

M.backward_lnum = function(lnum, virtcol)
	if lnum == 1 then
		return lnum
	end
	if
		M.head_p(lnum-1, virtcol, PARA2_TYPE2)
	then
		return lnum - 1
	end
	return M.backward_lnum(lnum - 1, virtcol)
end

M.forward_lnum = function(lnum, virtcol)
	if lnum == vim.fn.line("$") then
		return lnum
	end
	if
		M.tail_p(lnum+1, virtcol, PARA2_TYPE2)
	then
		return lnum + 1
	end
	return M.forward_lnum(lnum + 1, virtcol)
end

M.rep_call = function(func, arg1, arg2, count)
	if count == 0 then
		return func(arg1, arg2)
	else
		return M.rep_call(func, func(arg1, arg2), arg2, (count - 1))
	end
end

M.backward = function()
	local lnum_current = vim.fn.line(".")
	local virtcol = vim.fn.virtcol(".")
	local lnum_destination = M.rep_call(M.backward_lnum, lnum_current, virtcol, (vim.v.count1 - 1))
	vim.cmd(tostring(lnum_destination))
end

M.forward = function()
	local lnum_current = vim.fn.line(".")
	local virtcol = vim.fn.virtcol(".")
	local lnum_destination = M.rep_call(M.forward_lnum, lnum_current, virtcol, (vim.v.count1 - 1))
	vim.cmd(tostring(lnum_destination))
end



return M
