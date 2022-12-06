local status, indent_blankline = pcall(require, "indent_blankline")
if (not status) then return end

vim.opt.list = true
-- vim.opt.termguicolors = true
vim.cmd [[highlight IndentBlanklineIndent1 guifg=#586e75 gui=nocombine]]
-- vim.opt.listchars:append "space:⋅"

indent_blankline.setup({
  require("indent_blankline").setup {
    -- show_end_of_line = true,
    space_char_blankline = " ",
    char_highlight_list = {
      "IndentBlanklineIndent1",
    },
  }
})
