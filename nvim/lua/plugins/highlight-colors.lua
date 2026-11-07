vim.pack.add({ "https://github.com/brenoprata10/nvim-highlight-colors" })

-- Let nvim-highlight-colors render colors instead of the LSP
vim.lsp.document_color.enable(false)

require("nvim-highlight-colors").setup({
	render = "background",
	enable_hex = true,
	enable_short_hex = true,
	enable_rgb = true,
	enable_hsl = true,
	enable_hsl_without_function = true,
	enable_ansi = true,
	enable_var_usage = true,
	enable_tailwind = false,
})
