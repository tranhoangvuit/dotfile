-- Here is the formatting config
local null_ls = require("null-ls")
local lSsources = {
  null_ls.builtins.formatting.prettier.with({
    filetypes = {
      "javascript",
      "typescript",
      "javascriptreact",
      "typescriptreact",
      "css",
      "scss",
      "html",
      "json",
      "yaml",
      "markdown",
      "graphql",
      "md",
      "txt",
    },
  }),
  null_ls.builtins.formatting.goimports,
  null_ls.builtins.formatting.gofumpt,
  null_ls.builtins.formatting.stylua.with({
    filetypes = { "lua" },
    args = { "--indent-width", "2", "--indent-type", "Spaces", "-" },
  }),
  null_ls.builtins.diagnostics.golangci_lint,
  null_ls.builtins.formatting.rubocop,
  null_ls.builtins.diagnostics.rubocop,
}

require("null-ls").setup({
  sources = lSsources,
  on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
      vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({ bufnr = bufnr })
        end,
      })
    end
  end,
})
