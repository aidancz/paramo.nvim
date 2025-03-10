-- help functions

local H = {}

H.virtcol_cursor = function()
	return vim.fn.virtcol(".", true)[1]
end

H.virtcol_max_real = function(lnum)
-- HACK: this is REAL virtcol_max, use it with care
	if vim.o.list and vim.opt.listchars:get().eol ~= nil then
		return vim.fn.virtcol({lnum, "$"})
	else
		return
		math.max(1, vim.fn.virtcol({lnum, "$"}) - 1)
	end
end

H.width_editable_text = function()
	local wininfo = vim.fn.getwininfo(vim.fn.win_getid())[1]
	local textoff = wininfo.textoff
	local width = wininfo.width
	local width_editable_text = width - textoff
	-- https://stackoverflow.com/questions/26315925/get-usable-window-width-in-vim-script

	return width_editable_text
end

H.virtcol_quotient = function(virtcol)
	local width_editable_text = H.width_editable_text()
	-- local virtcol_quotient = virtcol // width_editable_text
	local virtcol_quotient = math.floor(virtcol / width_editable_text)
	return virtcol_quotient
end

H.virtcol_remainder = function(virtcol)
	local width_editable_text = H.width_editable_text()
	local virtcol_remainder = virtcol % width_editable_text
	return virtcol_remainder
end

H.backward_next = function(lnum, virtcol)
	local width_editable_text = H.width_editable_text()
	local virtcol_quotient = H.virtcol_quotient(virtcol)
	local virtcol_remainder = H.virtcol_remainder(virtcol)

	if virtcol_quotient > 0 then
		return lnum, virtcol - width_editable_text
	end
	if lnum == 1 then
		return nil, nil
	end
	return lnum - 1, H.virtcol_quotient(H.virtcol_max_real(lnum - 1)) * width_editable_text + virtcol_remainder
end

H.forward_next = function(lnum, virtcol)
	local width_editable_text = H.width_editable_text()
	local virtcol_quotient = H.virtcol_quotient(virtcol)
	local virtcol_remainder = H.virtcol_remainder(virtcol)

	if virtcol_quotient < H.virtcol_quotient(H.virtcol_max_real(lnum)) then
		return lnum, virtcol + width_editable_text
	end
	if lnum == vim.fn.line("$") then
		return nil, nil
	end
	return lnum + 1, virtcol_remainder
end

H.set_cursor = function(lnum, virtcol)
	local col = vim.fn.virtcol2col(0, lnum, virtcol)
	if virtcol >= vim.fn.virtcol({lnum, "$"}) then
	-- HACK: fix virtcol2col
		col = col + 1
	end

	local off
	local virtcol_max = vim.fn.virtcol({lnum, "$"})
	if virtcol > virtcol_max then
		off = virtcol - virtcol_max
	else
		off = 0
	end

	-- local curswant = H.virtcol_remainder(virtcol)
	-- local curswant = vim.fn.getcurpos()[5]
	local curswant = virtcol

	vim.fn.cursor({lnum, col, off, curswant})
end



H.empty_p = function(lnum)
	return vim.fn.getline(lnum) == ""
end

H.first_p = function(lnum)
	return lnum == 1
end

H.last_p = function(lnum)
	return lnum == vim.fn.line("$")
end



H.col_first_nonblank = function(lnum)
	local line = vim.fn.getline(lnum)
	local col1, col2 = string.find(line, "%S")
	return col1
end

H.virtcol_first_nonblank = function(lnum)
	local line = vim.fn.getline(lnum)
	local col1, col2 = string.find(line, "%S")
	if col1 == nil then return nil end
	return vim.fn.virtcol({lnum, col1}, true)[1]
end

H.empty_virtcol_p = function(lnum, virtcol)
	local virtcol_max = vim.fn.virtcol({lnum, "$"})
	local virtcol_first_nonblank = H.virtcol_first_nonblank(lnum)

	if virtcol_first_nonblank == nil then
	-- empty / contain only whitespace
		return true
	end
	if virtcol < virtcol_first_nonblank then
	-- before first non-blank char
		return true
	end
	if virtcol >= virtcol_max then
	-- beyond end char
		return true
	end
	return false
end



H.eq = function(a, b)
	return a == b
end

H.gt = function(a, b)
	return a > b
end

H.lt = function(a, b)
	return a < b
end

H.neq = function(a, b)
	return not H.eq(a, b)
end

H.ngt = function(a, b)
	return not H.gt(a, b)
end

H.nlt = function(a, b)
	return not H.lt(a, b)
end

H.any = function(a, b)
	return true
end

H.indent = function(lnum)
	local virtcol_first_nonblank = H.virtcol_first_nonblank(lnum)

	local indent
	if virtcol_first_nonblank then
	-- has non-blank char
		indent = virtcol_first_nonblank - 1
	elseif H.empty_p(lnum) then
	-- empty
		indent = -1
	else
	-- only whitespace
		indent = vim.fn.virtcol({lnum, "$"}) - 1
	end

	return indent
end



H.posgetchar = function(lnum, col)
	return
	vim.fn.strpart(
		vim.fn.getline(lnum),
		col - 1,
		1,
		true
	)
end

H.first_nonblank_char = function(lnum)
	local col_first_nonblank = H.col_first_nonblank(lnum)
	if col_first_nonblank then
		return H.posgetchar(lnum, col_first_nonblank)
	else
		return nil
	end
end

return H
