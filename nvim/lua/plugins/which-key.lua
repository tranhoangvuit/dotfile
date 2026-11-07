vim.pack.add({
	"https://github.com/folke/which-key.nvim",
})

require("which-key").setup({})

require("which-key").add({
	{ "<leader>a", group = "ai" },
	{ "<leader>b", group = "buffer" },
	{ "<leader>c", group = "code / copy" },
	{ "<leader>g", group = "git" },
	{ "<leader>m", group = "markdown" },
	{ "<leader>r", group = "review / rename" },
	{ "<leader>s", group = "symbols" },
	{ "<leader>t", group = "tab / terminal" },
	{ "<leader>x", group = "diagnostics" },
})
