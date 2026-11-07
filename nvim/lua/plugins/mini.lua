vim.pack.add({ "https://github.com/nvim-mini/mini.pairs" })

require("mini.pairs").setup({
	modes = { insert = true, command = true, terminal = false },
})
