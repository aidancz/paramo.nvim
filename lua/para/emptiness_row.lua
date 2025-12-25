local V = require("virtcol")

local H = {}
H.is_empty = function(pos)
	return vim.fn.getline(pos.lnum) == ""
end

---@param opts? {
---	empty?: boolean, @default false
---}
local F = function(opts)
	opts = vim.tbl_extend("force", {empty = false}, opts or {})

	local H = vim.deepcopy(H)
	if opts.empty == true then
		local f = H.is_empty
		H.is_empty = function(pos)
			return not f(pos)
		end
	end

	local P = setmetatable({}, {__index = H})
	P.is_head = function(pos)
		if
			not H.is_empty(pos)
			and
			(
				vim.tbl_isempty(V.prev_pos(pos))
				or
				H.is_empty(V.prev_pos(pos))
			)
		then
			return true
		else
			return false
		end
	end
	P.is_tail = function(pos)
		if
			not H.is_empty(pos)
			and
			(
				vim.tbl_isempty(V.next_pos(pos))
				or
				H.is_empty(V.next_pos(pos))
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
