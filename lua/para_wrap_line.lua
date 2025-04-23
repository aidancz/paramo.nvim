local H = vim.deepcopy(require("virtcol"))

local M = {}

M.is_head = function(pos)
	local width_editable_text = H.width_editable_text()

	if pos.virtcol <= width_editable_text then
		return true
	else
		return false
	end
end

M.is_tail = function(pos)
	local width_editable_text = H.width_editable_text()
	local virtcol_max_real = H.virtcol_max_real(pos.lnum)

	if pos.virtcol >= virtcol_max_real - (virtcol_max_real % width_editable_text) + 1 then
		return true
	else
		return false
	end
end

M.is_head_or_tail = function(pos)
	return M.is_head(pos) or M.is_tail(pos)
end

return M
