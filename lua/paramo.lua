local H = vim.deepcopy(require("virtcol"))

local M = {}

M.prev_pos = function(pos, is)
	local pos_candidate = H.prev_pos(pos)
	if next(pos_candidate) == nil then
		return {}
	end
	if is(pos_candidate) then
		return pos_candidate
	end
	return M.prev_pos(pos_candidate, is)
end

M.next_pos = function(pos, is)
	local pos_candidate = H.next_pos(pos)
	if next(pos_candidate) == nil then
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
	local pos = H.get_cursor()
	for _ = 1, count do
		if direction == "prev" then
			pos = M.prev_pos(pos, is)
		else
			pos = M.next_pos(pos, is)
		end
		if next(pos) == nil then return end
	end
	H.set_cursor(pos)
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

return M
