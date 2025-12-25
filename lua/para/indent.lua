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
H.compare_prev = function(indent_prev, indent_current)
	return indent_prev ~= indent_current
end
H.compare_next = function(indent_next, indent_current)
	return indent_next ~= indent_current
end
H.is_cursor_head = function(pos)
	return true
end
H.is_cursor_tail = function(pos)
	return true
end

---@param opts? {
---	indent_empty?: -1|"inherit_consistent_nonzero",
---	indent_block?: "special"|"general",
---	cursor_relevant?: false|true,
---}
local F = function(opts)
	opts = vim.tbl_extend(
		"force",
		{
			indent_empty = -1,
			indent_block = "special",
			cursor_relevant = false,
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
					prev_nonempty_indent == next_nonempty_indent
					and
					prev_nonempty_indent ~= 0
				then
					indent = prev_nonempty_indent
				end
			end
			return indent
		end
	end
	if opts.indent_block == "general" then
		H.compare_prev = function(indent_prev, indent_current)
			return indent_prev < indent_current
		end
		H.compare_next = function(indent_next, indent_current)
			return indent_next < indent_current
		end
	end
	if opts.cursor_relevant == true then
		H.is_cursor_head = function(pos)
			if
				vim.tbl_isempty(V.prev_pos(pos))
				or
				H.indent(V.prev_pos(pos).lnum) < H.indent(V.get_cursor().lnum)
			then
				return true
			else
				return false
			end
		end
		H.is_cursor_tail = function(pos)
			if
				vim.tbl_isempty(V.next_pos(pos))
				or
				H.indent(V.next_pos(pos).lnum) < H.indent(V.get_cursor().lnum)
			then
				return true
			else
				return false
			end
		end
	end

	local P = setmetatable({}, {__index = H})
	P.is_head = function(pos)
		if
			vim.tbl_isempty(V.prev_pos(pos))
			or
			H.compare_prev(
				H.indent(V.prev_pos(pos).lnum),
				H.indent(pos.lnum)
			)
		then
			return H.is_cursor_head(pos)
		else
			return false
		end
	end
	P.is_tail = function(pos)
		if
			vim.tbl_isempty(V.next_pos(pos))
			or
			H.compare_next(
				H.indent(V.next_pos(pos).lnum),
				H.indent(pos.lnum)
			)
		then
			return H.is_cursor_tail(pos)
		else
			return false
		end
	end

	return P
end

return F
