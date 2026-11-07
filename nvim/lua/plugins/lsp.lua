vim.pack.add({
    "https://github.com/neovim/nvim-lspconfig"
})

-- Per-server settings live in after/lsp/<server>.lua
vim.lsp.config('*', {
	capabilities = require('blink.cmp').get_lsp_capabilities({
		workspace = {
			fileOperations = {
				didRename = true,
				willRename = true,
			},
		},
	}),
})

vim.lsp.enable({
	'ty',            -- also $ uv tool install ty@latest
	'ruff',          -- also $ uv tool install ruff@latest
	'lua_ls',        -- also $ brew install lua-language-server
	'gopls',         -- also $ brew install gopls
	'vtsls',         -- also $ npm i -g @vtsls/language-server  (TS/JS, Next.js, RN, TanStack Start)
	'eslint',        -- also $ npm i -g vscode-langservers-extracted
	'oxlint',        -- also $ npm i -g oxlint
	'cssls',         -- also $ npm i -g vscode-langservers-extracted
	'tailwindcss',   -- also $ npm i -g @tailwindcss/language-server
	'rust_analyzer', -- also $ rustup component add rust-analyzer
})

-- eslint: fix on save (formatting itself is done by conform's format_on_save)
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

-- Diagnostics
local icons = require('utils.icons')
vim.diagnostic.config({
	underline = true,
	update_in_insert = false,
	virtual_text = {
		spacing = 4,
		source = 'if_many',
		prefix = '●',
		format = function(diagnostic)
			if diagnostic.code then
				return string.format('%s (%s: %s)', diagnostic.message, diagnostic.source, diagnostic.code)
			end
			return diagnostic.message
		end,
	},
	severity_sort = true,
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = icons.diagnostics.Error,
			[vim.diagnostic.severity.WARN] = icons.diagnostics.Warn,
			[vim.diagnostic.severity.HINT] = icons.diagnostics.Hint,
			[vim.diagnostic.severity.INFO] = icons.diagnostics.Info,
		},
	},
})

-- Goto source definition (vtsls) or implementation
local function goto_source_definition()
	local clients = vim.lsp.get_clients({ bufnr = 0, name = 'vtsls' })
	if #clients == 0 then
		return vim.lsp.buf.implementation()
	end
	local params = vim.lsp.util.make_position_params(0, 'utf-16')
	clients[1]:request('workspace/executeCommand', {
		command = 'typescript.goToSourceDefinition',
		arguments = { params.textDocument.uri, params.position },
	}, function(err, result)
		if err then
			vim.notify('goToSourceDefinition: ' .. err.message, vim.log.levels.ERROR)
			return
		end
		if result and #result > 0 then
			vim.lsp.util.show_document(result[1], 'utf-16', { focus = true })
		else
			vim.notify('No source definition found', vim.log.levels.INFO)
		end
	end, 0)
end

-- Keymaps
vim.keymap.set('n', 'gd', function() Snacks.picker.lsp_definitions({ jump = { reuse_win = false } }) end,
	{ desc = 'Go to definition' })
vim.keymap.set('n', 'gD', function() Snacks.picker.lsp_declarations() end, { desc = 'Go to declaration' })
vim.keymap.set('n', 'gy', function() Snacks.picker.lsp_type_definitions() end, { desc = 'Go to type definition' })
vim.keymap.set('n', 'gr', function() Snacks.picker.lsp_references() end, { desc = 'References', nowait = true })
vim.keymap.set('n', 'gI', goto_source_definition, { desc = 'Go to source definition / implementation' })
vim.keymap.set('n', 'gK', vim.lsp.buf.signature_help, { desc = 'Signature help' })
vim.keymap.set('i', '<C-k>', vim.lsp.buf.signature_help, { desc = 'Signature help' })
vim.keymap.set('n', '<C-j>', function() vim.diagnostic.jump({ count = 1, float = true }) end,
	{ desc = 'Next diagnostic' })
vim.keymap.set({ 'n', 'x' }, '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code action' })
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'Rename symbol' })
