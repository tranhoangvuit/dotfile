local status, mason = pcall(require, "mason")
if (not status) then return end
local status2, lspconfig = pcall(require, "mason-lspconfig")
if (not status2) then return end

mason.setup({
  ensure_installed = { "sumneko_lua", "rust_analyzer", "gopls", "golangci_lint_ls" }
})

require("lspconfig").gopls.setup {}
require("lspconfig").golangci_lint_ls.setup {}

lspconfig.setup {
  automatic_installation = true
}
