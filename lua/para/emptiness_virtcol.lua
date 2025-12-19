local V = require("virtcol")

local H = {}
H.virtcol_first_nonblank = function(lnum)
	local line = vim.fn.getline(lnum)
	local col1, col2 = string.find(line, "%S")
	if col1 == nil then return nil end
	return vim.fn.virtcol({lnum, col1}, true)[1]
end
H.is_empty = function(pos)
	local virtcol_max = vim.fn.virtcol({pos.lnum, "$"})
	local virtcol_first_nonblank = H.virtcol_first_nonblank(pos.lnum)

	if virtcol_first_nonblank == nil then
	-- empty / contain only whitespace
		return true
	end
	if pos.virtcol < virtcol_first_nonblank then
	-- before first non-blank char
		return true
	end
	if pos.virtcol >= virtcol_max then
	-- beyond end char
		return true
	end
	return false
end

---@param opts? {
---	empty?: boolean, @default true
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

	return
	{
		is_head = function(pos)
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
		end,
		is_tail = function(pos)
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
		end,
	}
end

return F
