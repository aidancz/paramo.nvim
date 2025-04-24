paramo.nvim enhances vertical movement in nvim

for example:

```
xxx█xxxx	-- your cursor here
xxxxxxxx
xxx█xxxx	-- you want your cursor positioned here, but no builtin motion does this

xxxxxxxx
xxxxxxxx
```

paramo.nvim handles `wrapped lines` gracefully and plays nicely with `virtualedit`

# install

[paramo.nvim](https://github.com/aidancz/paramo.nvim) depends on [virtcol.nvim](https://github.com/aidancz/virtcol.nvim), make sure both are installed

for example, with [mini.deps](https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-deps.md):

```lua
require("mini.deps").add({
	source = "aidancz/paramo.nvim",
	depends = {
		{
			source = "aidancz/virtcol.nvim",
		},
	},
})
```

# quick start

add these codes to your config and see if you can figure out what these keymaps mean 😊

<details>

<summary>⭐click me⭐</summary>

```lua
local map = function(key, direction, is, hook)
	vim.keymap.set(
		{"n", "x", "o"},
		key,
		function()
			return
			require("paramo").expr({
				direction = direction,
				is = is,
				hook = hook,
			})
		end,
		{expr = true}
	)
end

map("{", "prev", require("para_nonempty_reverse").is_head_or_tail)
map("}", "next", require("para_nonempty_reverse").is_head_or_tail)

map("<a-u>", "prev", require("para_nonempty").is_head)
map("<a-d>", "next", require("para_nonempty").is_tail)

map("<a-w>", "next", require("para_cursor_column").is_head)
map("<a-e>", "next", require("para_cursor_column").is_tail)
map("<a-b>", "prev", require("para_cursor_column").is_head)

local caret = function() vim.cmd("normal! ^") end
map("<pageup>",   "prev", require("para_cursor_indent").is_head_or_tail, caret)
map("<pagedown>", "next", require("para_cursor_indent").is_head_or_tail, caret)
map(
	"<",
	"next",
	function(pos)
		return
		require("para_cursor_indent").is_head(
			pos,
			function(a, b)
				return a < b
			end
		)
	end,
	caret
)
map(
	">",
	"next",
	function(pos)
		return
		require("para_cursor_indent").is_head(
			pos,
			function(a, b)
				return a > b
			end
		)
	end,
	caret
)
map(
	"(",
	"prev",
	function(pos)
		return
		require("para_cursor_indent").is_head(
			pos,
			function(a, b)
				return a < b
			end
		)
	end,
	caret
)
map(
	")",
	"prev",
	function(pos)
		return
		require("para_cursor_indent").is_head(
			pos,
			function(a, b)
				return a > b
			end
		)
	end,
	caret
)
```

</details>

> [!NOTE]
>
> throughout this readme, it's recommended to set `vim.o.virtualedit = "all"` to clearly observe how the motions behave

# glossary

`pos` refers to a table with `lnum` and `virtcol` fields, for example:

```lua
{
	lnum = 37,
	virtcol = 42,
}
```

`is` refers to a function that takes a `pos` and returns a boolean, for example:

```lua
function(pos)
	if pos.lnum % 2 == 0 then
		return false
	else
		return true
	end
end
```

# require("paramo").expr

this is a wrapper function for easily creating expression mappings

for example, you can create a motion that moves cursor to the next pos that lnum is even:

```lua
vim.keymap.set(
	{"n", "x", "o"},
	"<down>",
	function()
		return
		require("paramo").expr({
			direction = "next",
			is = function(pos)
				if pos.lnum % 2 == 0 then
					return false
				else
					return true
				end
			end
		})
	end,
	{expr = true}
)
```

# `is` function

`paramo.nvim` has many `is` functions builtin

for example, `lua/para_nonempty.lua` provide 3 `is` functions:

```
require("para_nonempty").is_head
require("para_nonempty").is_tail
require("para_nonempty").is_head_or_tail
```

more `is` functions can be found at `lua/para_xxxx.lua` file

# virtcol.nvim

the vertical movement ability of `paramo.nvim` comes from `virtcol.nvim`,

for example, you can simulate the builtin `gj` with:

```lua
vim.keymap.set(
	"n",
	"<down>",
	function()
		local m = require("virtcol")
		m.set_cursor(m.next_pos(m.get_cursor()))
	end
)
```

for details, check its source code

# textobjects

paramo.nvim does not have any textobjects built in

however, you can use the api together with other textobjects plugins to get the desired textobjects

for example, indent textobjects (`ii`, `ai`, `io`, `ao`) with [mini.ai](https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-ai.md):

<details>

<summary>⭐click me⭐</summary>

```lua
require("mini.ai").setup({
	custom_textobjects = {
		i = function(ai_type)
			local is_head
			local is_tail
			if ai_type == "i" then
				is_head = require("para_cursor_indent").is_head
				is_tail = require("para_cursor_indent").is_tail
			else
				is_head = require("para_cursor_indent_include_empty_line").is_head
				is_tail = require("para_cursor_indent_include_empty_line").is_tail
			end

			local pos_head
			local pos_tail
			local pos_cursor = require("virtcol").get_cursor()
			if is_head(pos_cursor) then
				pos_head = pos_cursor
			else
				pos_head = require("paramo").prev_pos(pos_cursor, is_head)
			end
			if is_tail(pos_cursor) then
				pos_tail = pos_cursor
			else
				pos_tail = require("paramo").next_pos(pos_cursor, is_tail)
			end

			return {
				from = {
					line = pos_head.lnum,
					col = 1,
				},
				to = {
					line = pos_tail.lnum,
					col = 1,
				},
				vis_mode = "V",
			}
		end,

		o = function(ai_type)
			local is_head
			local is_tail
			if ai_type == "i" then
				is_head = require("para_cursor_ondent").is_head
				is_tail = require("para_cursor_ondent").is_tail
			else
				is_head = require("para_cursor_ondent_include_empty_line").is_head
				is_tail = require("para_cursor_ondent_include_empty_line").is_tail
			end

			local pos_head
			local pos_tail
			local pos_cursor = require("virtcol").get_cursor()
			if is_head(pos_cursor) then
				pos_head = pos_cursor
			else
				pos_head = require("paramo").prev_pos(pos_cursor, is_head)
			end
			if is_tail(pos_cursor) then
				pos_tail = pos_cursor
			else
				pos_tail = require("paramo").next_pos(pos_cursor, is_tail)
			end

			return {
				from = {
					line = pos_head.lnum,
					col = 1,
				},
				to = {
					line = pos_tail.lnum,
					col = 1,
				},
				vis_mode = "V",
			}
		end,
})
```

</summary>

# related plugins

https://github.com/jessekelighine/vindent.vim
