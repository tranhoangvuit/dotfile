require("snacks").setup({
    opts = {
    scroll = {
      enabled = false, -- Disable scrolling animations
    },
    picker = {
      previewers = {
        diff = { builtin = false },
        git = { builtin = false },
      },
      debug = { scores = false, leaks = false, explorer = false, files = false, proc = true },
      sources = {
        files = {
          hidden = true,
        },
        grep = {
          hidden = true,
        },
        explorer = {
          hidden = true,
          layout = {
            preset = "sidebar",
            preview = { main = true, enabled = false },
          },
        },
      },
      win = {
        input = {
          keys = {
            ["<c-l>"] = { "toggle_lua", mode = { "n", "i" } },
          },
        },
      },
      actions = {
        toggle_lua = function(p)
          local opts = p.opts --[[@as snacks.picker.grep.Config]]
          opts.ft = not opts.ft and "lua" or nil
          p:find()
        end,
      },
    },
    explorer = { enabled = true },
    indent = {
      chunk = { enabled = true },
    },
    lazygit = {
      enabled = true,
    },
    statuscolumn = {
      enabled = true,
    },
  },
  keys = {
    -- Picker
    {
      ";f",
      function()
        Snacks.picker.files()
      end,
      desc = "Find files",
    },
    {
      ";r",
      function()
        Snacks.picker.grep()
      end,
      desc = "Live grep",
    },
    {
      "\\\\",
      function()
        Snacks.picker.buffers()
      end,
      desc = "List buffers",
    },
    {
      ";t",
      function()
        Snacks.picker.help()
      end,
      desc = "Help tags",
    },
    {
      ";;",
      function()
        Snacks.picker.resume()
      end,
      desc = "Resume picker",
    },
    {
      "<leader>ss",
      function()
        Snacks.picker.lsp_symbols()
      end,
      desc = "LSP document symbols",
    },
    {
      "<leader>sS",
      function()
        Snacks.picker.lsp_workspace_symbols()
      end,
      desc = "LSP workspace symbols",
    },
    {
      "<leader>fP",
      function()
        Snacks.picker.files({ cwd = require("lazy.core.config").options.root })
      end,
      desc = "Find plugin file",
    },
    -- Lazygit
    {
      "<leader>lg",
      function()
        Snacks.lazygit()
      end,
      desc = "Lazygit",
    },
    -- Utils
  },
})
