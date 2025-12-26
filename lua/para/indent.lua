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
---	indent_empty?: -1|"inherit_min_nonzero",
---	type?: "=="|">="|"==."|">=.",
---}
local F = function(opts)
	opts = vim.tbl_extend(
		"force",
		{
			indent_empty = -1,
			type = "==",
		},
		opts or {}
	)

	local H = vim.deepcopy(H)
	if opts.indent_empty == "inherit_min_nonzero" then
		local f = H.indent
		H.indent = function(lnum)
			local indent = f(lnum)
			if indent == -1 then
				local prev_nonempty_indent = H.fetch_prev_nonempty_indent(lnum)
				local next_nonempty_indent = H.fetch_next_nonempty_indent(lnum)
				local min = math.min(prev_nonempty_indent, next_nonempty_indent)
				if
					min ~= 0
				then
					indent = min
				end
			end
			return indent
		end
	end

	H.indent_pos = function(pos)
		if vim.tbl_isempty(pos) then
			return -1
		else
			return H.indent(pos.lnum)
		end
	end

	local P = setmetatable({}, {__index = H})
	if opts.type == "==" then
		P.is_head = function(pos)
			return
				H.indent_pos(pos) ~= H.indent_pos(V.prev_pos(pos))
		end
		P.is_tail = function(pos)
			return
				H.indent_pos(pos) ~= H.indent_pos(V.next_pos(pos))
		end
		return P
	end
	if opts.type == "==." then
		P.is_head = function(pos)
			return
				H.indent_pos(pos) ~= H.indent_pos(V.prev_pos(pos))
				and
				H.indent_pos(pos) == H.indent_pos(V.get_cursor())
		end
		P.is_tail = function(pos)
			return
				H.indent_pos(pos) ~= H.indent_pos(V.next_pos(pos))
				and
				H.indent_pos(pos) == H.indent_pos(V.get_cursor())
		end
		return P
	end
	if opts.type == ">=" then
		P.is_head = function(pos)
			return
				H.indent_pos(pos) > H.indent_pos(V.prev_pos(pos))
		end
		P.is_tail = function(pos)
			return
				H.indent_pos(pos) > H.indent_pos(V.next_pos(pos))
		end
		return P
	end
	if opts.type == ">=." then
		P.is_head = function(pos)
			return
				H.indent_pos(pos) > H.indent_pos(V.prev_pos(pos))
				and
				(
					H.indent_pos(pos) >= H.indent_pos(V.get_cursor())
					and
					H.indent_pos(V.get_cursor()) > H.indent_pos(V.prev_pos(pos))
				)
		end
		P.is_tail = function(pos)
			return
				H.indent_pos(pos) > H.indent_pos(V.next_pos(pos))
				and
				(
					H.indent_pos(pos) >= H.indent_pos(V.get_cursor())
					and
					H.indent_pos(V.get_cursor()) > H.indent_pos(V.next_pos(pos))
				)
		end
		return P
	end
end

return F
