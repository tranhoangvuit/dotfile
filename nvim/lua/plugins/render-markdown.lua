vim.pack.add({ "https://github.com/MeanderingProgrammer/render-markdown.nvim" })

-- Render markdown in the buffer (raw text is shown on the cursor line)
require("render-markdown").setup({
	file_types = { "markdown", "mdx" },
	completions = { blink = { enabled = true } },
})

vim.keymap.set("n", "<leader>mp", "<cmd>RenderMarkdown toggle<cr>", { desc = "Toggle markdown render" })
vim.keymap.set("n", "<leader>ms", "<cmd>RenderMarkdown preview<cr>", { desc = "Markdown preview in side split" })
