-- help functions

local M = {}

M.virtcol = function(lnum, col)
	return vim.fn.virtcol({lnum, col})
end

M.virtcol_max = function(lnum)
	return vim.fn.virtcol({lnum, "$"})
end

M.width_editable_text = function()
	local wininfo = vim.fn.getwininfo(vim.fn.win_getid())[1]
	local textoff = wininfo.textoff
	local width = wininfo.width
	local width_editable_text = width - textoff
	-- https://stackoverflow.com/questions/26315925/get-usable-window-width-in-vim-script

	return width_editable_text
end

M.empty_p = function(lnum)
	return vim.fn.getline(lnum) == ""
end

M.first_p = function(lnum)
	return lnum == 1
end

M.last_p = function(lnum)
	return lnum == vim.fn.line("$")
end

M.empty_virtcol_p = function(lnum, virtcol)
	local virtcol_max = M.virtcol_max(lnum)

	if virtcol >= virtcol_max then
		return true
		-- beyond end char
	else
		local col = vim.fn.virtcol2col(0, lnum, virtcol)
		local char = vim.api.nvim_buf_get_text(0, lnum-1, col-1, lnum-1, col-1+1, {})[1]
		local prestr = vim.api.nvim_buf_get_text(0, lnum-1, 0, lnum-1, col-1+1, {})[1]

		if (char == " " or char == "\t") and prestr:match("^%s+$") ~= nil then
			return true
			-- before first non-blank char
		else
			return false
			-- first non-blank char to end char
		end
	end
end

M.backward = function(terminate_p, first_call)
	if first_call then
		require("paramo/para0").ensure_head()
		require("paramo/para0").backward(require("paramo/para0").head_p)
	else
		vim.cmd("normal! gk")
	end
	if
		terminate_p()
		or
		M.first_p()
	then
		require("paramo/para0").ensure_head()
		return
	end
	return M.backward(terminate_p)
end

M.forward = function(terminate_p, first_call)
	if first_call then
		require("paramo/para0").ensure_head()
		require("paramo/para0").forward(require("paramo/para0").head_p)
	else
		vim.cmd("normal! gj")
	end
	if
		terminate_p()
		or
		M.last_p()
	then
		require("paramo/para0").ensure_head()
		return
	end
	return M.forward(terminate_p)
end

return M
