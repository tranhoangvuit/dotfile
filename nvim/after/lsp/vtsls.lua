---@type vim.lsp.Config
return {
	on_attach = function(client)
		if client and client.server_capabilities.semanticTokensProvider then
			client.server_capabilities.semanticTokensProvider.range = false
		end
	end,
	settings = {
		complete_function_calls = true,
		vtsls = {
			enableMoveToFileCodeAction = true,
			autoUseWorkspaceTsdk = true,
			experimental = {
				maxInlayHintLength = 30,
				completion = { enableServerSideFuzzyMatch = true },
			},
		},
		typescript = {
			-- inlay hints + auto-import preferences for monorepos
			inlayHints = {
				parameterNames = { enabled = "literals" },
				parameterTypes = { enabled = true },
				variableTypes = { enabled = true },
				propertyDeclarationTypes = { enabled = true },
				functionLikeReturnTypes = { enabled = true },
				enumMemberValues = { enabled = true },
			},
			updateImportsOnFileMove = { enabled = "always" },
			suggest = { completeFunctionCalls = true },
			preferences = {
				importModuleSpecifier = "non-relative",
				useAliasesForRenames = false,
			},
		},
		javascript = {
			inlayHints = {
				parameterNames = { enabled = "literals" },
				variableTypes = { enabled = true },
			},
		},
	},
}
