vim.pack.add({
    "https://github.com/neovim/nvim-lspconfig"
})

vim.lsp.enable({
	'ty',            -- also $ uv tool install ty@latest
	'ruff',          -- also $ uv tool install ruff@latest
	'lua_ls',        -- also $ brew install lua-language-server
	'gopls',         -- also $ brew install gopls
	'vtsls',         -- also $ npm i -g @vtsls/language-server  (TS/JS, Next.js, RN, TanStack Start)
	'eslint',        -- also $ npm i -g vscode-langservers-extracted
	'tailwindcss',   -- also $ npm i -g @tailwindcss/language-server
})

-- vtsls: enable inlay hints + auto-import preferences for monorepos
vim.lsp.config('vtsls', {
	settings = {
		typescript = {
			inlayHints = {
				parameterNames = { enabled = 'literals' },
				parameterTypes = { enabled = true },
				variableTypes = { enabled = true },
				propertyDeclarationTypes = { enabled = true },
				functionLikeReturnTypes = { enabled = true },
				enumMemberValues = { enabled = true },
			},
			updateImportsOnFileMove = { enabled = 'always' },
			preferences = { importModuleSpecifier = 'non-relative' },
		},
		javascript = {
			inlayHints = {
				parameterNames = { enabled = 'literals' },
				variableTypes = { enabled = true },
			},
		},
		vtsls = {
			experimental = { completion = { enableServerSideFuzzyMatch = true } },
		},
	},
})

-- eslint: fix on save
vim.api.nvim_create_autocmd('LspAttach', {
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if client and client.name == 'eslint' then
			vim.api.nvim_create_autocmd('BufWritePre', {
				buffer = ev.buf,
				command = 'LspEslintFixAll',
			})
		end
	end,
})
vim.o.signcolumn = 'yes' -- make lsp warnings not widen the gutter
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to definition' })
-- Auto-format ("lint") on save (adapted from neovim docs :help auto-format)
vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('my.lsp', { clear = true }),
	callback = function(ev)
		local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
		if not client:supports_method('textDocument/willSaveWaitUntil')
		    and client:supports_method('textDocument/formatting') then
			vim.api.nvim_create_autocmd('BufWritePre', {
				group = vim.api.nvim_create_augroup('my.lsp.fmt', { clear = false }),
				buffer = ev.buf,
				callback = function()
					vim.lsp.buf.format({ bufnr = ev.buf, id = client.id, timeout_ms = 1000 })
				end,
			})
		end
	end,
})
