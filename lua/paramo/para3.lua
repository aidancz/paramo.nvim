local M = {}
local H = require("paramo/parah")

M.head_p = function(lnum, col)
	lnum = lnum or vim.fn.line(".")
	col = col or vim.fn.col(".")

	local virtcol = H.virtcol(lnum, col)

	if
		not H.empty_virtcol_p(lnum, virtcol)
		and
		(
			H.first_p(lnum)
			or
			H.empty_virtcol_p(lnum - 1, virtcol)
		)
	then
		return true
	else
		return false
	end
end

M.tail_p = function(lnum, col)
	lnum = lnum or vim.fn.line(".")
	col = col or vim.fn.col(".")

	local virtcol = H.virtcol(lnum, col)

	if
		not H.empty_virtcol_p(lnum, virtcol)
		and
		(
			H.last_p(lnum)
			or
			H.empty_virtcol_p(lnum + 1, virtcol)
		)
	then
		return true
	else
		return false
	end
end

M.head_or_tail_p = function()
	return M.head_p() or M.tail_p()
end

M.backward = require("paramo/parah").backward
M.forward = require("paramo/parah").forward

return M
