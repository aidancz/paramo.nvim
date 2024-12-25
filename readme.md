paramo.nvim provides 3 kinds of paragraph motions:

- para0
- para1
- para2

# demo

## para0

![](assets/para0.png)

how can we move cursor to the last screen line of current logical line?

para0 is here for you!

## para1

![](assets/para1.png)

how can we move cursor to the last line above empty line?

para1 is here for you!

para1 is like the `{` and `}` motions but before the empty line

## para2

![](assets/para2.png)

how can we move cursor to the last line that has visible character?

para2 is here for you!

para2 is like the `E` and `B` motions but vertical

please `:set cursorcolumn` to understand the concept of para2

# setup

## setup example 1:

```
require("paramo").setup({
	{
		type = "para0",
		backward = "{",
		forward = "}",
	},
	{
		type = "para1",
		backward = "(",
		forward = ")",
	},
	{
		type = "para2",
		backward = "<home>",
		forward = "<end>",
	},
})
```

## setup example 2:

if you want `para1` only:

```
require("paramo").setup({
	{
		type = "para1",
		backward = "{",
		forward = "}",
	},
})
```

## setup example 3:

if you are using `lazy.nvim`:

```
{
	"aidancz/paramo.nvim",
	config = function()
		require("paramo").setup({
			{
				type = "para0",
				backward = "{",
				forward = "}",
			},
			{
				type = "para1",
				backward = "(",
				forward = ")",
			},
			{
				type = "para2",
				backward = "<home>",
				forward = "<end>",
			},
		})
	end,
}
```

# note

this plugin places the cursor on the logical line rather than the screen line

if you want to place the cursor on the screen line, the code of `para0` might be useful to you
