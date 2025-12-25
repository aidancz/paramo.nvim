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

M.pos_is_in_range = function(pos, range)
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
	-- NOTE: have no effect yet, implement the simplest case above

	local head2range = function(head)
		if para.is_tail(head) then
			return {head, head}
		else
			return {head, M.next_pos(head, para.is_tail)}
		end
	end
	local tail2range = function(tail)
		if para.is_head(tail) then
			return {tail, tail}
		else
			return {M.prev_pos(tail, para.is_head), tail}
		end
	end

	local pos_cursor = V.get_cursor()

	local pos_prev_head = M.prev_pos(pos_cursor, para.is_head)
	local pos_next_head = M.next_pos(pos_cursor, para.is_head)

	if para.is_head(pos_cursor) then
		return head2range(pos_cursor)
	end
	if para.is_tail(pos_cursor) then
		return tail2range(pos_cursor)
	end
	if vim.tbl_isempty(pos_prev_head) and vim.tbl_isempty(pos_next_head) then
		return {{}, {}}
	end
	if vim.tbl_isempty(pos_prev_head) then
		local range_next_head = head2range(pos_next_head)
		return range_next_head
	end
	if vim.tbl_isempty(pos_next_head) then
		local range_prev_head = head2range(pos_prev_head)
		if M.pos_is_in_range(pos_cursor, range_prev_head) then
			return range_prev_head
		else
			return {{}, {}}
		end
	end
	if true then
		local range_prev_head = head2range(pos_prev_head)
		local range_next_head = head2range(pos_next_head)
		if M.pos_is_in_range(pos_cursor, range_prev_head) then
			return range_prev_head
		else
			return range_next_head
		end
	end
end

return M
