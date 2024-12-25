local M = {}

M.setup = function(config)
	for _, i in ipairs(config) do

		local para = require("paramo/" .. i.type)

		vim.keymap.set(
			{"n", "x"},
			i.backward,
			function()
				for i = 1, vim.v.count1 do
					para.backward()
				end
			end,
			{}
		)

		vim.keymap.set(
			{"n", "x"},
			i.forward,
			function()
				for i = 1, vim.v.count1 do
					para.forward()
				end
			end,
			{}
		)

		vim.keymap.set(
			"o",
			i.backward,
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

				return "<cmd>normal " .. vis_mode .. vim.v.count1 .. i.backward .. "<cr>"
			end,
			{expr = true}
		)

		vim.keymap.set(
			"o",
			i.forward,
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

				return "<cmd>normal " .. vis_mode .. vim.v.count1 .. i.forward .. "<cr>"
			end,
			{expr = true}
		)

	end
end

return M
