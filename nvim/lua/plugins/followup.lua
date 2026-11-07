-- Local plugin: lua/followup (todo lists per project + global, due dates)
local followup = require("followup")

followup.setup()

vim.keymap.set("n", "<leader>nn", function() followup.open() end, { desc = "Todo list (project)" })
vim.keymap.set("n", "<leader>nN", function() followup.open({ global = true }) end, { desc = "Todo list (global)" })
vim.keymap.set("n", "<leader>na", function() followup.prompt() end, { desc = "Add todo" })
vim.keymap.set("n", "<leader>nA", function() followup.prompt({ link = true }) end, { desc = "Add todo linked to cursor" })
vim.keymap.set("n", "<leader>ng", function() followup.prompt({ global = true }) end, { desc = "Add global todo" })
vim.keymap.set("n", "<leader>nf", function() followup.find() end, { desc = "Find open todos" })
vim.keymap.set("n", "<leader>nd", function() followup.check_due({ verbose = true }) end, { desc = "Show due todos" })
