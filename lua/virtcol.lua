local M = {}

M.width_editable_text = function()
-- https://stackoverflow.com/questions/26315925/get-usable-window-width-in-vim-script
	if vim.wo.wrap == false then
		return vim.v.maxcol
	end
	local wininfo = vim.fn.getwininfo(vim.fn.win_getid())[1]
	local textoff = wininfo.textoff
	local width = wininfo.width
	local width_editable_text = width - textoff
	return width_editable_text
end

M.virtcol_division = function(virtcol)
	local dividend = virtcol
	local divisor = M.width_editable_text()
	local quotient = math.floor(dividend / divisor) -- lua 5.1 does not support // operator
	local remainder = dividend % divisor

	if remainder == 0 then
		-- edge case
		quotient = quotient - 1
		remainder = divisor
	end

	return {
		dividend = dividend,
		divisor = divisor,
		quotient = quotient,
		remainder = remainder,
	}
end

M.char_virtcol_min = function(lnum, col)
	return vim.fn.virtcol({lnum, col}, true)[1]
end

M.char_virtcol_max = function(lnum, col)
	return vim.fn.virtcol({lnum, col}, true)[2]
end

M.line_virtcol_max_logical = function(lnum)
	return vim.fn.virtcol({lnum, "$"})
end

M.line_virtcol_max_visible = function(lnum)
	local line_virtcol_max_logical = M.line_virtcol_max_logical(lnum)
	if vim.o.list and vim.opt.listchars:get().eol ~= nil then
		return line_virtcol_max_logical
	else
		return math.max(1, line_virtcol_max_logical - 1)
	end
end

M.line_virtcol_max_display = function(lnum)
	local line_virtcol_max_visible = M.line_virtcol_max_visible(lnum)
	local division = M.virtcol_division(line_virtcol_max_visible)
	return division.divisor * (division.quotient + 1)
end

M.get_cursor = function()
	local lnum = vim.fn.line(".")
	local curswant = vim.fn.getcurpos()[5]

	local line_virtcol_max_display = M.line_virtcol_max_display(lnum)

	local virtcol = math.min(line_virtcol_max_display, curswant)

	return {
		lnum = lnum,
		virtcol = virtcol,
	}
end

M.posgetchar = function(lnum, col)
	return vim.fn.strpart(vim.fn.getline(lnum), col - 1, 1, true)
end
-- `:h strpart()` has an example that get the char under the cursor:
-- `strpart(getline("."), col(".") - 1, 1, v:true)`

M.virtcol2col = function(lnum, virtcol)
	local col = vim.fn.virtcol2col(0, lnum, virtcol)
	local line_virtcol_max_logical = M.line_virtcol_max_logical(lnum)
	if col == 0 then
	-- empty line
		col = 1
	elseif virtcol >= line_virtcol_max_logical then
	-- not empty line, but pos is at/beyond eol
		col = col + string.len(M.posgetchar(lnum, col))
	end
	return col
end
-- fix vim.fn.virtcol2col to work with eol

M.virtcol2off = function(lnum, virtcol)
	local off
	local line_virtcol_max_logical = M.line_virtcol_max_logical(lnum)
	if virtcol >= line_virtcol_max_logical then
		off = virtcol - line_virtcol_max_logical
	else
		local col = M.virtcol2col(lnum, virtcol)
		local char_virtcol_min = M.char_virtcol_min(lnum, col)
		off = virtcol - char_virtcol_min
	end
	return off
end

M.set_cursor = function(pos)
	local lnum = pos.lnum
	local virtcol = pos.virtcol
	local col = M.virtcol2col(lnum, virtcol)
	local off = M.virtcol2off(lnum, virtcol)

	vim.fn.cursor({lnum, col, off, virtcol})
end

M.prev_pos = function(pos)
	local division = M.virtcol_division(pos.virtcol)

	if division.quotient > 0 then
		return {
			lnum = pos.lnum,
			virtcol = pos.virtcol - division.divisor,
		}
	end

	if pos.lnum == 1 then
		return {}
	end

	local division_prev = M.virtcol_division(M.line_virtcol_max_visible(pos.lnum - 1))
	return {
		lnum = pos.lnum - 1,
		virtcol = division_prev.divisor * division_prev.quotient + division.remainder,
	}
end

M.next_pos = function(pos)
	local division = M.virtcol_division(pos.virtcol)

	local division_curr = M.virtcol_division(M.line_virtcol_max_visible(pos.lnum))
	if division.quotient < division_curr.quotient then
		return {
			lnum = pos.lnum,
			virtcol = pos.virtcol + division.divisor,
		}
	end

	if pos.lnum == vim.fn.line("$") then
		return {}
	end

	return {
		lnum = pos.lnum + 1,
		virtcol = division.remainder,
	}
end

return M
