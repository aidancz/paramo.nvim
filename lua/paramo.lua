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

M.set_cursor = function(direction, count, is)
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

-- the following is for dot-repeat

M.cache = {
	direction = nil,
	count = nil,
	is = nil,
}

M.update_cache = function(direction, is)
	M.cache.direction = direction
	M.cache.count = vim.v.count1
	M.cache.is = is
end

M.apply_cache = function()
	M.set_cursor(
		M.cache.direction,
		vim.v.count == 0 and M.cache.count or vim.v.count,
		M.cache.is
	)
end

M.new = function(direction, is)
	M.update_cache(direction, is)
	M.apply_cache()
end

-- the following is for expr mapping

M.expr = function(opts)
	M.update_cache(opts.direction, opts.is)
	vim.o.operatorfunc = [[v:lua.require'paramo'.apply_cache]]
	return "g@l"
end

return M
