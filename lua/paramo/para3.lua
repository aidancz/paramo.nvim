local M = {}

-- # config & setup

M.config = {
	include_more_indent = false,
	include_empty_lines = false,
}

M.setup = function(config)
	M.config = vim.tbl_deep_extend("force", M.config, config or {})

	local para3_xx
	local a = M.config.include_more_indent
	local b = M.config.include_empty_lines
	if not a then
		if not b then
			para3_xx = require("paramo/para3_00")
		else
			para3_xx = require("paramo/para3_01")
		end
	else
		if not b then
			para3_xx = require("paramo/para3_10")
		else
			para3_xx = require("paramo/para3_11")
		end
	end
	setmetatable(M, {__index = para3_xx})
end

return M
