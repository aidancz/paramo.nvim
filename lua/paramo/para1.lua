local M = {}
local H = require("paramo/parah")

M.head_p = function(lnum)
	lnum = lnum or vim.fn.line(".")

	if
		not H.empty_p(lnum)
		and
		(
			H.first_p(lnum)
			or
			H.empty_p(lnum - 1)
		)
	then
		return true
	else
		return false
	end
end

M.tail_p = function(lnum)
	lnum = lnum or vim.fn.line(".")

	if
		not H.empty_p(lnum)
		and
		(
			H.last_p(lnum)
			or
			H.empty_p(lnum + 1)
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
