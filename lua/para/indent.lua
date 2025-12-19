local V = require("virtcol")

local H = {}
H.virtcol_first_nonblank = function(lnum)
	local line = vim.fn.getline(lnum)
	local col1, col2 = string.find(line, "%S")
	if col1 == nil then return nil end
	return vim.fn.virtcol({lnum, col1}, true)[1]
end
H.indent = function(lnum)
	local virtcol_first_nonblank = H.virtcol_first_nonblank(lnum)

	local indent
	if virtcol_first_nonblank then
	-- has non-blank char
		indent = virtcol_first_nonblank - 1
	elseif vim.fn.getline(lnum) == "" then
	-- empty
		indent = -1
	else
	-- only whitespace
		indent = vim.fn.virtcol({lnum, "$"}) - 1
	end

	return indent
end
H.fetch_prev_nonempty_indent = function(lnum)
	if (lnum - 1) < 1 then
		return 0
	end
	if H.indent(lnum - 1) ~= -1 then
		return H.indent(lnum - 1)
	end
	return H.fetch_prev_nonempty_indent(lnum - 1)
end
H.fetch_next_nonempty_indent = function(lnum)
	if (lnum + 1) > vim.fn.line("$") then
		return 0
	end
	if H.indent(lnum + 1) ~= -1 then
		return H.indent(lnum + 1)
	end
	return H.fetch_next_nonempty_indent(lnum + 1)
end

---@param opts? {
---	indent_empty?: -1|"inherit_consistent_nonzero",
---	compare_prev?: function,
---	compare_next?: function,
---}
local F = function(opts)
	opts = vim.tbl_extend(
		"force",
		{
			indent_empty = -1,
			compare_prev = function(indent_prev, indent_current)
				return indent_prev ~= indent_current
			end,
			compare_next = function(indent_next, indent_current)
				return indent_next ~= indent_current
			end,
		},
		opts or {}
	)

	local H = vim.deepcopy(H)
	if opts.indent_empty == "inherit_consistent_nonzero" then
		local f = H.indent
		H.indent = function(lnum)
			local indent = f(lnum)
			if indent == -1 then
				local prev_nonempty_indent = H.fetch_prev_nonempty_indent(lnum)
				local next_nonempty_indent = H.fetch_next_nonempty_indent(lnum)
				if
					prev_nonempty_indent ~= 0
					and
					prev_nonempty_indent == next_nonempty_indent
				then
					indent = prev_nonempty_indent
				end
			end
			return indent
		end
	end

	return
	{
		is_head = function(pos)
			if
				vim.tbl_isempty(V.prev_pos(pos))
				or
				opts.compare_prev(
					H.indent(V.prev_pos(pos).lnum),
					H.indent(pos.lnum)
				)
			then
				return true
			else
				return false
			end
		end,
		is_tail = function(pos)
			if
				vim.tbl_isempty(V.next_pos(pos))
				or
				opts.compare_next(
					H.indent(V.next_pos(pos).lnum),
					H.indent(pos.lnum)
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
