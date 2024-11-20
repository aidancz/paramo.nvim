local M = {}



local para1 = require("paramo/para1")
local para2 = require("paramo/para2")



M.setup = function(config)

-- # para1

if config.para1_backward ~= "" then
	vim.keymap.set({"n", "x"}, config.para1_backward, para1.backward)
	vim.keymap.set("o", config.para1_backward,
		function()
			return ([=[<cmd>normal V%s%s<cr>]=]):format(vim.v.count1, config.para1_backward)
		end,
		{expr = true})
end

if config.para1_forward ~= "" then
	vim.keymap.set({"n", "x"}, config.para1_forward, para1.forward)
	vim.keymap.set("o", config.para1_forward,
		function()
			return ([=[<cmd>normal V%s%s<cr>]=]):format(vim.v.count1, config.para1_forward)
		end,
		{expr = true})
end
-- https://vi.stackexchange.com/questions/6101/is-there-a-text-object-for-current-line/6102#6102

-- # para2

if config.para2_backward ~= "" then
	vim.keymap.set({"n", "x"}, config.para2_backward, para2.backward)
	vim.keymap.set("o", config.para2_backward,
		function()
			return ([=[<cmd>normal V%s%s<cr>]=]):format(vim.v.count1, config.para2_backward)
		end,
		{expr = true})
end

if config.para2_forward ~= "" then
	vim.keymap.set({"n", "x"}, config.para2_forward, para2.forward)
	vim.keymap.set("o", config.para2_forward,
		function()
			return ([=[<cmd>normal V%s%s<cr>]=]):format(vim.v.count1, config.para2_forward)
		end,
		{expr = true})
end

end



return M
