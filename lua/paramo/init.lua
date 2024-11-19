local para1 = require("paramo/para1")
local para2 = require("paramo/para2")



-- # para1

vim.keymap.set({"n", "v"}, "(", para1.backward)
vim.keymap.set({"n", "v"}, ")", para1.forward)
vim.keymap.set("o", "(", function() return "<cmd>normal V" .. vim.v.count1 .. "(<cr>" end, {expr = true})
vim.keymap.set("o", ")", function() return "<cmd>normal V" .. vim.v.count1 .. ")<cr>" end, {expr = true})
-- https://vi.stackexchange.com/questions/6101/is-there-a-text-object-for-current-line/6102#6102



-- # para2

vim.keymap.set({"n", "v"}, "<home>", para2.backward)
vim.keymap.set({"n", "v"}, "<end>",  para2.forward)
vim.keymap.set("o", "<home>", function() return "<cmd>normal V" .. vim.v.count1 .. "<home><cr>" end, {expr = true})
vim.keymap.set("o", "<end>",  function() return "<cmd>normal V" .. vim.v.count1 .. "<end><cr>"  end, {expr = true})
