return {
  -- Completion engine
  "saghen/blink.cmp",
  version = "v1.*", -- use prebuilt fuzzy binaries
  event = { "InsertEnter", "CmdlineEnter" },
  dependencies = {
    "neovim/nvim-lspconfig",
    "rafamadriz/friendly-snippets",
    "fang2hou/blink-copilot",
  },
  opts = {
    --
    -- All presets have the following mappings:
    -- C-y: Accept
    -- C-space: Open menu or open docs if already open
    -- C-n/C-p or Up/Down: Select next/previous item
    -- C-e: Hide menu
    -- C-k: Toggle signature help (if signature.enabled = true)
    --
    keymap = {
      ["<Tab>"] = {
        "snippet_forward",
        "fallback",
      },
    },
    signature = { enabled = true },
    windows = {
      autocomplete = { border = "rounded" },
      documentation = { border = "rounded" },
      signature_help = { border = "rounded" },
    },
    fuzzy = { implementation = "prefer_rust_with_warning" },
    sources = {
      default = { "lsp", "path", "buffer", "snippets" },
      providers = {
        copilot = {
          name = "copilot",
          module = "blink-copilot",
          score_offset = 100,
          async = true,
          opts = {
            -- Local options override global ones
            max_completions = 3, -- Override global max_completions

            -- Final settings:
            -- * max_completions = 3
            -- * max_attempts = 2
            -- * all other options are default
          },
        },
        -- codeium = { name = "Codeium", module = "codeium.blink", async = true },
      },
    },
  },
  config = function(_, opts)
    require("blink.cmp").setup(opts)
  end,
}
