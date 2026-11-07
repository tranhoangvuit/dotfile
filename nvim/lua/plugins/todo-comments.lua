vim.pack.add({ "https://github.com/folke/todo-comments.nvim" })

require("todo-comments").setup()

vim.keymap.set("n", ";T", function() Snacks.picker.todo_comments() end, { desc = "Todo comments" })
