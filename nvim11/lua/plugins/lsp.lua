return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        copilot = {}, -- manual LSP configuration
      },
    },
    {
      "mason-org/mason.nvim",
      opts = { ensure_installed = { "copilot-language-server" } },
    },
    {
      "saghen/blink.cmp",
      dependencies = { "fang2hou/blink-copilot" },
      opts = {
        sources = {
          default = { "lsp", "path", "snippets", "buffer", "copilot" },
          providers = {
            copilot = {
              name = "copilot",
              module = "blink-copilot",
              async = true,
            },
          },
        },
      },
    },
  },
}
