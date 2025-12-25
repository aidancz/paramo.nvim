local V = require("virtcol")

local H = {}

---@param opts? {
---}
local F = function(opts)
	local H = vim.deepcopy(H)

	local P = setmetatable({}, {__index = H})
	P.is_head = function(pos)
		local width_editable_text = V.width_editable_text()

		if pos.virtcol <= width_editable_text then
			return true
		else
			return false
		end
	end
	P.is_tail = function(pos)
		local width_editable_text = V.width_editable_text()
		local virtcol_max_real = V.virtcol_max_real(pos.lnum)

		if pos.virtcol >= virtcol_max_real - (virtcol_max_real % width_editable_text) + 1 then
			return true
		else
			return false
		end
	end

	return P
end

return F
