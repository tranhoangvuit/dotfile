vim.pack.add({ "https://github.com/stevearc/conform.nvim" })

local web = { "oxfmt", "prettierd", "prettier", stop_after_first = true }

require("conform").setup({
	default_format_opts = {
		timeout_ms = 3000,
		async = false,
		quiet = false,
		lsp_format = "fallback",
	},
	formatters_by_ft = {
		lua = { "stylua" },
		go = { "goimports", "gofmt", stop_after_first = true },
		python = { "ruff_format", "isort", "black", stop_after_first = true },
		json = web,
		jsonc = web,
		javascript = web,
		typescript = web,
		javascriptreact = web,
		typescriptreact = web,
		css = web,
		scss = web,
		less = web,
		html = web,
		yaml = web,
		markdown = web,
		["markdown.mdx"] = web,
		graphql = web,
		xml = { "prettier", stop_after_first = true }, -- oxfmt doesn't support xml
		toml = { "taplo" },
		nix = { "nixfmt" },
		sh = { "shfmt" },
		fish = { "fish_indent" },
	},
	formatters = {
		oxfmt = {
			-- Treat oxfmt as available only when the project has an oxfmt config
			-- (.oxfmtrc.json / .oxfmtrc.jsonc). Without it, fall back to prettier.
			require_cwd = true,
		},
	},
	-- Toggle per buffer with :ToggleFormatter
	format_on_save = function(bufnr)
		if vim.b[bufnr].disable_autoformat then
			return
		end
		return { timeout_ms = 500, lsp_format = "fallback" }
	end,
})

vim.keymap.set({ "n", "x" }, "<leader>f", function()
	require("conform").format()
end, { desc = "Format code" })

vim.keymap.set({ "n", "v" }, "<leader>cF", function()
	require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
end, { desc = "Format Injected Langs" })
