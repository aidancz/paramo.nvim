local M = {}



M.setup = function(config)
	for _, i in ipairs(config) do



-- # para0

if i.type == "para0" then
	vim.keymap.set({"n", "x"}, i.backward, require("paramo/para0").backward)
	vim.keymap.set("o", i.backward,
		function()
			return ([=[<cmd>normal V%s%s<cr>]=]):format(vim.v.count1, i.backward)
		end,
		{expr = true})

	vim.keymap.set({"n", "x"}, i.forward, require("paramo/para0").forward)
	vim.keymap.set("o", i.forward,
		function()
			return ([=[<cmd>normal V%s%s<cr>]=]):format(vim.v.count1, i.forward)
		end,
		{expr = true})
end

-- # para1

if i.type == "para1" then
	vim.keymap.set({"n", "x"}, i.backward,
		function()
			require("paramo/para1").backward()
			if i.screen_or_logical_column == "screen" then
				local para0 = require("paramo/para0")
				if not para0.head_p() then
					para0.backward()
				end
			end
		end)
	vim.keymap.set("o", i.backward,
		function()
			return ([=[<cmd>normal V%s%s<cr>]=]):format(vim.v.count1, i.backward)
		end,
		{expr = true})

	vim.keymap.set({"n", "x"}, i.forward,
		function()
			require("paramo/para1").forward()
			if i.screen_or_logical_column == "screen" then
				local para0 = require("paramo/para0")
				if not para0.tail_p() then
					para0.forward()
				end
			end
		end)
	vim.keymap.set("o", i.forward,
		function()
			return ([=[<cmd>normal V%s%s<cr>]=]):format(vim.v.count1, i.forward)
		end,
		{expr = true})
end

-- # para2

if i.type == "para2" then
	vim.keymap.set({"n", "x"}, i.backward,
		function()
			require("paramo/para2").backward()
			if i.screen_or_logical_column == "screen" then
				local para0 = require("paramo/para0")
				if not para0.head_p() then
					para0.backward()
				end
			end
		end)
	vim.keymap.set("o", i.backward,
		function()
			return ([=[<cmd>normal V%s%s<cr>]=]):format(vim.v.count1, i.backward)
		end,
		{expr = true})

	vim.keymap.set({"n", "x"}, i.forward,
		function()
			require("paramo/para2").forward()
			if i.screen_or_logical_column == "screen" then
				local para0 = require("paramo/para0")
				if not para0.tail_p() then
					para0.forward()
				end
			end
		end)
	vim.keymap.set("o", i.forward,
		function()
			return ([=[<cmd>normal V%s%s<cr>]=]):format(vim.v.count1, i.forward)
		end,
		{expr = true})
end



	end
end



return M
