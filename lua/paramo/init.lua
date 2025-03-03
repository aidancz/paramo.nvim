local M = {}

M.setup = function(config)
	for _, i in ipairs(config or {}) do

		local para = require("paramo/" .. i.type)

		for headtail, keymap in pairs(i.backward or {}) do
			vim.keymap.set(
				{"n", "x"},
				keymap,
				function()
					if para.setup then para.setup(i.type_config) end

					local f = load("return para." .. headtail .. "_p")
					setfenv(f, {para = para})
					for n = 1, vim.v.count1 do
						para.backward(f())
					end
				end,
				{}
			)

			vim.keymap.set(
				"o",
				keymap,
				function()
					local mode = vim.api.nvim_get_mode().mode
					local vis_mode
					if mode == "no"    then vis_mode = "V"     end
					if mode == "nov"   then vis_mode = "v"     end
					if mode == "noV"   then vis_mode = "V"     end
					if mode == "no\22" then vis_mode = "<c-v>" end

					local cache_selection = vim.o.selection
					vim.o.selection = "exclusive"
					vim.schedule(function()
						vim.o.selection = cache_selection
					end)

					return "<cmd>normal " .. vis_mode .. vim.v.count1 .. keymap .. "<cr>"
				end,
				{expr = true}
			)
		end

		for headtail, keymap in pairs(i.forward or {}) do
			vim.keymap.set(
				{"n", "x"},
				keymap,
				function()
					if para.setup then para.setup(i.type_config) end

					local f = load("return para." .. headtail .. "_p")
					setfenv(f, {para = para})
					for n = 1, vim.v.count1 do
						para.forward(f())
					end
				end,
				{}
			)

			vim.keymap.set(
				"o",
				keymap,
				function()
					local mode = vim.api.nvim_get_mode().mode
					local vis_mode
					if mode == "no"    then vis_mode = "V"     end
					if mode == "nov"   then vis_mode = "v"     end
					if mode == "noV"   then vis_mode = "V"     end
					if mode == "no\22" then vis_mode = "<c-v>" end

					local cache_selection = vim.o.selection
					vim.o.selection = "exclusive"
					vim.schedule(function()
						vim.o.selection = cache_selection
					end)

					return "<cmd>normal " .. vis_mode .. vim.v.count1 .. keymap .. "<cr>"
				end,
				{expr = true}
			)
		end

	end
end

M.get_head_and_tail = function(para_type, para_type_config)
	local para = require("paramo/" .. para_type)
	if para.setup then para.setup(para_type_config) end

	if debug.getinfo(para.head_p).nparams == 1 then
		local lnum_cursor = vim.fn.line(".")

		local lnum_bh = para.backward_pos(lnum_cursor, para.head_p)
		local lnum_bt = para.backward_pos(lnum_cursor, para.tail_p)
		local lnum_fh = para.forward_pos(lnum_cursor, para.head_p)
		local lnum_ft = para.forward_pos(lnum_cursor, para.tail_p)

		local lnum_1
		if para.head_p(lnum_cursor) then
			lnum_1 = lnum_cursor
		else
			if lnum_bh and ((not lnum_bt) or (lnum_bh >= lnum_bt)) then
				lnum_1 = lnum_bh
			else
				lnum_1 = nil
			end
		end

		local lnum_2
		if para.tail_p(lnum_cursor) then
			lnum_2 = lnum_cursor
		else
			if lnum_ft and ((not lnum_fh) or (lnum_ft <= lnum_fh)) then
				lnum_2 = lnum_ft
			else
				lnum_2 = nil
			end
		end

		return
		{
			head = lnum_1,
			tail = lnum_2,
		}
	end

	if debug.getinfo(para.head_p).nparams == 2 then
		local lnum_cursor = vim.fn.line(".")
		local virtcol_cursor = require("paramo/parah").virtcol_cursor()

		local lnum_bh = para.backward_pos(lnum_cursor, virtcol_cursor, para.head_p)
		local lnum_bt = para.backward_pos(lnum_cursor, virtcol_cursor, para.tail_p)
		local lnum_fh = para.forward_pos(lnum_cursor, virtcol_cursor, para.head_p)
		local lnum_ft = para.forward_pos(lnum_cursor, virtcol_cursor, para.tail_p)

		local lnum_1
		if para.head_p(lnum_cursor, virtcol_cursor) then
			lnum_1 = lnum_cursor
		else
			if lnum_bh and ((not lnum_bt) or (lnum_bh >= lnum_bt)) then
				lnum_1 = lnum_bh
			else
				lnum_1 = nil
			end
		end

		local lnum_2
		if para.tail_p(lnum_cursor, virtcol_cursor) then
			lnum_2 = lnum_cursor
		else
			if lnum_ft and ((not lnum_fh) or (lnum_ft <= lnum_fh)) then
				lnum_2 = lnum_ft
			else
				lnum_2 = nil
			end
		end

		return
		{
			head = lnum_1,
			tail = lnum_2,
		}
	end
end

return M
