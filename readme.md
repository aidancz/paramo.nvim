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

# install

## general

1. install
2. setup

### setup example 1:

```
require("paramo").setup({
	{
		type = "para0",
		backward = "{",
		forward = "}",
	},
	{
		type = "para1",
		screen_or_logical_column = "screen",
		backward = "(",
		forward = ")",
	},
	{
		type = "para2",
		screen_or_logical_column = "screen",
		backward = "<home>",
		forward = "<end>",
	},
})
```

### setup example 2:

if you want `para1` only:

```
require("paramo").setup({
	{
		type = "para1",
		screen_or_logical_column = "screen",
		backward = "{",
		forward = "}",
	},
})
```

### setup example 3:

if you want to test the difference between `screen_or_logical_column = "screen"` and `screen_or_logical_column = "logical"`, you may:

```
require("paramo").setup({
	{
		type = "para1",
		screen_or_logical_column = "screen",
		backward = "{",
		forward = "}",
	},
	{
		type = "para1",
		screen_or_logical_column = "logical",
		backward = "(",
		forward = ")",
	},
})
```

basically

the option `screen_or_logical_column` is meaningful only when lines are wrapped

the option `screen_or_logical_column` controls whether the cursor should stay on the screen column or the logical column

as a result

`para0` does not have this option

`para1` has this option

`para2` has this option

## lazy.nvim

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
				screen_or_logical_column = "screen",
				backward = "(",
				forward = ")",
			},
			{
				type = "para2",
				screen_or_logical_column = "screen",
				backward = "<home>",
				forward = "<end>",
			},
		})
	end,
}
```
