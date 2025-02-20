-- help functions

local M = {}

M.type = function(lnum, virtcol)
	local PARA_TYPE0 = 0
	-- empty line
	local PARA_TYPE1 = 1
	-- before first non-blank char
	local PARA_TYPE2 = 2
	-- first non-blank char to end char
	local PARA_TYPE3 = 3
	-- beyond end char

	local virtcol_max = vim.fn.virtcol({lnum, "$"})

	if virtcol_max == 1 then
		return PARA_TYPE0
	elseif virtcol >= virtcol_max then
		return PARA_TYPE3
	else
		local col = vim.fn.virtcol2col(0, lnum, virtcol)
		local char = vim.api.nvim_buf_get_text(0, lnum-1, col-1, lnum-1, col-1+1, {})[1]
		local prestr = vim.api.nvim_buf_get_text(0, lnum-1, 0, lnum-1, col-1+1, {})[1]

		if (char == " " or char == "\t") and prestr:match("^%s+$") ~= nil then
			return PARA_TYPE1
		else
			return PARA_TYPE2
		end
	end
end

M.backward = function(terminate_p, first_call)
	if first_call then
		local terminate_p_origin = terminate_p
		terminate_p = function()
			return
			terminate_p_origin()
			or
			vim.fn.line(".") == 1
		end
		require("paramo/para0").backward(require("paramo/para0").head_p)
		if terminate_p() then
			require("paramo/para0").ensure_head()
			return
		end
	end
	vim.cmd("normal! gk")
	if terminate_p() then
		require("paramo/para0").ensure_head()
		return
	end
	return M.backward(terminate_p)
end

M.forward = function(terminate_p, first_call)
	if first_call then
		local terminate_p_origin = terminate_p
		terminate_p = function()
			return
			terminate_p_origin()
			or
			vim.fn.line(".") == vim.fn.line("$")
		end
		require("paramo/para0").forward(require("paramo/para0").head_p)
		if terminate_p() then
			require("paramo/para0").ensure_head()
			return
		end
	end
	vim.cmd("normal! gj")
	if terminate_p() then
		require("paramo/para0").ensure_head()
		return
	end
	return M.forward(terminate_p)
end

return M
