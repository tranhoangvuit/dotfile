local onedarkpro = require("onedarkpro")
local utils = require("onedarkpro.utils")
onedarkpro.setup({
  theme = "onedark",
  hlgroups = {
    Whitespace = { fg = "#282c34" },
  }, -- Override default highlight groups
  filetype_hlgroups = {}, -- Override default highlight groups for specific filetypes
  plugins = { -- Override which plugins highlight groups are loaded
    native_lsp = true,
    polygot = true,
    treesitter = true,
    telescope = true,
  },
})
onedarkpro.load()
