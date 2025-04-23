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

M.set_cursor_opts = function(opts)
	M.set_cursor(opts.count, opts.direction, opts.is)
end

-- the following is for dot-repeat

M.cache = {
	count = nil,
	direction = nil,
	is = nil,
}

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

M.apply_cache = function()
	M.start_visual_mode()
	if vim.v.count ~= 0 then
		M.cache.count = vim.v.count
	end
	M.set_cursor_opts(M.cache)
end

---@param opts {
---	direction: "prev"|"next",
---	is: function,
---}
M.expr = function(opts)
	opts.count = vim.v.count1

	local mode = vim.api.nvim_get_mode().mode
	if string.sub(mode, 1, 2) ~= "no" then
		vim.schedule(function()
			M.set_cursor_opts(opts)
		end)
	else
		M.cache = opts
		return
		[[<cmd>lua require("paramo").apply_cache()<cr>]]
	end
end

return M
