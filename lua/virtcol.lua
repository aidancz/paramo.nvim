local M = {}

M.get_cursor = function()
	local virtcol_min, virtcol_max = unpack(vim.fn.virtcol(".", true))
	local curswant = vim.fn.getcurpos()[5]
	local virtcol
	if curswant >= virtcol_min and curswant <= virtcol_max then
		virtcol = curswant
	else
		virtcol = virtcol_min
	end
	return
	{
		lnum = vim.fn.line("."),
		virtcol = virtcol,
	}
end

M.posgetchar = function(lnum, col)
	return
	vim.fn.strpart(
		vim.fn.getline(lnum),
		col - 1,
		1,
		true
	)
end

M.set_cursor = function(pos)
	local virtcol_max = vim.fn.virtcol({pos.lnum, "$"})

	local col = vim.fn.virtcol2col(0, pos.lnum, pos.virtcol)
	if col == 0 then
		col = 1
	elseif pos.virtcol >= virtcol_max then
		col = col + string.len(M.posgetchar(pos.lnum, col))
	end
	-- fix virtcol2col

	local off
	if pos.virtcol >= virtcol_max then
		off = pos.virtcol - virtcol_max
	else
		off = pos.virtcol - vim.fn.virtcol({pos.lnum, col}, true)[1]
	end

	-- vim.print({pos.lnum, col, off, pos.virtcol})
	vim.fn.cursor({pos.lnum, col, off, pos.virtcol})
end

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

	return
	{
		dividend = dividend,
		divisor = divisor,
		quotient = quotient,
		remainder = remainder,
	}
end

M.virtcol_max_real = function(lnum)
-- this is **real** virtcol_max, use it with care
	if vim.o.list and vim.opt.listchars:get().eol ~= nil then
		return vim.fn.virtcol({lnum, "$"})
	else
		return
		math.max(1, vim.fn.virtcol({lnum, "$"}) - 1)
	end
end

M.prev_pos = function(pos)
	local division = M.virtcol_division(pos.virtcol)

	if division.quotient > 0 then
		return
		{
			lnum = pos.lnum,
			virtcol = pos.virtcol - division.divisor,
		}
	end
	if pos.lnum == 1 then
		return
		{
		}
	end

	local division_prev_line_virtcol_max_real = M.virtcol_division(M.virtcol_max_real(pos.lnum - 1))
	return
	{
		lnum = pos.lnum - 1,
		virtcol = (
			division_prev_line_virtcol_max_real.quotient
			*
			division_prev_line_virtcol_max_real.divisor
			+
			division.remainder
		),
	}
end

M.next_pos = function(pos)
	local division = M.virtcol_division(pos.virtcol)

	local division_current_line_virtcol_max_real = M.virtcol_division(M.virtcol_max_real(pos.lnum))
	if division.quotient < division_current_line_virtcol_max_real.quotient then
		return
		{
			lnum = pos.lnum,
			virtcol = pos.virtcol + division.divisor,
		}
	end
	if pos.lnum == vim.fn.line("$") then
		return
		{
		}
	end
	return
	{
		lnum = pos.lnum + 1,
		virtcol = division.remainder,
	}
end

return M
