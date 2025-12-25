local V = require("virtcol")

local H = {}
H.col_first_nonblank = function(lnum)
	local line = vim.fn.getline(lnum)
	local col1, col2 = string.find(line, "%S")
	return col1
end
H.first_nonblank_char = function(lnum)
	local col_first_nonblank = H.col_first_nonblank(lnum)
	if col_first_nonblank then
		return V.posgetchar(lnum, col_first_nonblank)
	else
		return nil
	end
end

---@param opts? {
---}
local F = function(opts)
	local H = vim.deepcopy(H)

	local P = setmetatable({}, {__index = H})
	P.is_head = function(pos)
		if
			(
				vim.tbl_isempty(V.prev_pos(pos))
				or
				H.first_nonblank_char(V.prev_pos(pos).lnum) ~= H.first_nonblank_char(pos.lnum)
			)
		then
			return true
		else
			return false
		end
	end
	P.is_tail = function(pos)
		if
			(
				vim.tbl_isempty(V.next_pos(pos))
				or
				H.first_nonblank_char(V.next_pos(pos).lnum) ~= H.first_nonblank_char(pos.lnum)
			)
		then
			return true
		else
			return false
		end
	end

	return P
end

return F
