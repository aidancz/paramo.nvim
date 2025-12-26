local V = require("virtcol")

local M = {}

M.prev_pos = function(pos, is)
	local pos_candidate = V.prev_pos(pos)
	if vim.tbl_isempty(pos_candidate) then
		return {}
	end
	if is(pos_candidate) then
		return pos_candidate
	end
	return M.prev_pos(pos_candidate, is)
end

M.next_pos = function(pos, is)
	local pos_candidate = V.next_pos(pos)
	if vim.tbl_isempty(pos_candidate) then
		return {}
	end
	if is(pos_candidate) then
		return pos_candidate
	end
	return M.next_pos(pos_candidate, is)
end

---@param count number
---@param direction "prev"|"next"
---@param is function
M.set_cursor = function(count, direction, is)
	local pos = V.get_cursor()
	for _ = 1, count do
		if direction == "prev" then
			pos = M.prev_pos(pos, is)
		else
			pos = M.next_pos(pos, is)
		end
		if vim.tbl_isempty(pos) then return end
	end
	V.set_cursor(pos)
	vim.cmd("normal! zv")
end

-- # the following is for dot-repeat

M.cache_n = {
-- normal mode (include visual mode)
	count = 1,
	direction = "next",
	is = function(pos) return true end,
}

M.cache_o = {
-- operator pending mode
	count = 1,
	direction = "next",
	is = function(pos) return true end,
}

M.cache_n_apply = function()
	if vim.v.count ~= 0 then
		M.cache_n.count = vim.v.count
	end
	M.set_cursor(
		M.cache_n.count,
		M.cache_n.direction,
		M.cache_n.is
	)
end

M.cache_o_apply = function()
	if vim.v.count ~= 0 then
		M.cache_o.count = vim.v.count
	end
	M.start_visual_mode()
	M.set_cursor(
		M.cache_o.count,
		M.cache_o.direction,
		M.cache_o.is
	)
end

---@param opts? {
---	count?: number,
---	direction?: "prev"|"next",
---	is?: function,
---}
M.expr = function(opts)
	if M.is_operator_pending_mode() then
		M.cache_o = vim.tbl_extend(
			"force",
			{
				count = 1,
				direction = "next",
				is = function(pos) return true end,
			},
			opts or {}
		)
		return [[<cmd>lua require("paramo").cache_o_apply()<cr>]]
	else
		M.cache_n = vim.tbl_extend(
			"force",
			{
				count = 1,
				direction = "next",
				is = function(pos) return true end,
			},
			opts or {}
		)
		return [[<cmd>lua require("paramo").cache_n_apply()<cr>]]
	end
end

M.is_operator_pending_mode = function()
	local mode = vim.api.nvim_get_mode().mode
	return string.sub(mode, 1, 2) == "no"
end

M.start_visual_mode = function()
	local mode = vim.api.nvim_get_mode().mode

	local vis_mode
	if mode == "no"    then vis_mode = "V"   end
	-- linewise by default
	if mode == "nov"   then vis_mode = "v"   end
	if mode == "noV"   then vis_mode = "V"   end
	if mode == "no\22" then vis_mode = "\22" end

	local cache_selection = vim.o.selection
	vim.o.selection = "exclusive"
	vim.schedule(function()
		vim.o.selection = cache_selection
	end)

	vim.cmd("normal! " .. vis_mode)
end

-- # the following is for para textobject

M.range_is_empty = function(range)
	return vim.deep_equal(range, {{}, {}})
end

M.pos_is_in_range = function(pos, range)
	if M.range_is_empty(range) then
		return false
	end
	if pos.lnum < range[1].lnum then
		return false
	end
	if pos.lnum > range[2].lnum then
		return false
	end
	if pos.lnum == range[1].lnum and pos.virtcol < range[1].virtcol then
		return false
	end
	if pos.lnum == range[2].lnum and pos.virtcol > range[2].virtcol then
		return false
	end
	return true
end

M.head2range = function(head, is_tail)
	if vim.tbl_isempty(head) then
		return {{}, {}}
	end
	if is_tail(head) then
		return {head, head}
	end
	return {head, M.next_pos(head, is_tail)}
end

M.tail2range = function(tail, is_head)
	if vim.tbl_isempty(tail) then
		return {{}, {}}
	end
	if is_head(tail) then
		return {tail, tail}
	end
	return {M.prev_pos(tail, is_head), tail}
end

---@param opts? {
---	search_method?: "cover"|"next"|"prev"|"cover_or_next"|"cover_or_prev",
---}
M.find_para = function(para, opts)
	opts = vim.tbl_extend(
		"force",
		{
			n_lines = "unlimited",
			n_times = 1,
			reference_region = "cursor",
			search_method = "cover_or_next",
		},
		opts or {}
	)
	-- NOTE: require("mini.ai").find_textobject
	-- NOTE: partly implemented

	local range_cover
	local range_next
	local range_prev
	local select_range = function()
		if opts.search_method == "cover" then
			return range_cover()
		end
		if opts.search_method == "next" then
			return range_next()
		end
		if opts.search_method == "prev" then
			return range_prev()
		end
		if opts.search_method == "cover_or_next" then
			return
				not M.range_is_empty(range_cover())
				and
				range_cover()
				or
				range_next()
		end
		if opts.search_method == "cover_or_prev" then
			return
				not M.range_is_empty(range_cover())
				and
				range_cover()
				or
				range_prev()
		end
	end

	local pos_cursor = V.get_cursor()

	local range_empty = function()
		return {{}, {}}
	end
	local range_cursor_head = function()
		return M.head2range(pos_cursor, para.is_tail)
	end
	local range_cursor_tail = function()
		return M.tail2range(pos_cursor, para.is_head)
	end
	local range_next_head = function()
		local pos_next_head = M.next_pos(pos_cursor, para.is_head)
		return M.head2range(pos_next_head, para.is_tail)
	end
	local range_next_tail = function()
		local pos_next_tail = M.next_pos(pos_cursor, para.is_tail)
		return M.tail2range(pos_next_tail, para.is_head)
	end
	local range_prev_head = function()
		local pos_prev_head = M.prev_pos(pos_cursor, para.is_head)
		return M.head2range(pos_prev_head, para.is_tail)
	end
	local range_prev_tail = function()
		local pos_prev_tail = M.prev_pos(pos_cursor, para.is_tail)
		return M.tail2range(pos_prev_tail, para.is_head)
	end

	if para.is_head(pos_cursor) then
		range_cover = range_cursor_head
		range_next = range_next_head
		range_prev = range_prev_head
		return select_range()
	end
	if para.is_tail(pos_cursor) then
		range_cover = range_cursor_tail
		range_next = range_next_tail
		range_prev = range_prev_tail
		return select_range()
	end
	if true then
		if M.pos_is_in_range(pos_cursor, range_prev_head()) then
			range_cover = range_prev_head
			range_next = range_next_head
			range_prev = range_prev_tail
		else
			range_cover = range_empty
			range_next = range_next_head
			range_prev = range_prev_head
		end
		return select_range()
	end
end

return M
