local M = {}

M.setup = function(config)
	for _, i in ipairs(config) do

		local para = require("paramo/" .. i.type)

		for head_or_tail, keymap in pairs(i.backward or {}) do
			vim.keymap.set(
				{"n", "x"},
				keymap,
				function()
					local f = load("return para." .. head_or_tail .. "_p")
					setfenv(f, {para = para})
					for n = 1, vim.v.count1 do
						para.backward(f(), true)
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

		for head_or_tail, keymap in pairs(i.forward or {}) do
			vim.keymap.set(
				{"n", "x"},
				keymap,
				function()
					local f = load("return para." .. head_or_tail .. "_p")
					setfenv(f, {para = para})
					for n = 1, vim.v.count1 do
						para.forward(f(), true)
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

return M
