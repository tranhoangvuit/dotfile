local nightfox = require("nightfox")
nightfox.setup({
  options = {
    dim_active = true,
    styles = {
      comments = "italic",
      keywords = "bold",
      functions = "italic,bold",
    },
    inverse = {
      visual = true,
      search = true,
      match_paren = true,
    },
  },
})

vim.api.nvim_exec(
  [[
function! MyHighlights() abort
    highlight CursorLine guifg=NONE guibg=#353A54
    highlight CmpItemAbbr guifg=#9FA4B6
    highlight SpecialKey guibg=NONE
    highlight CmpItemKind guifg=#8289A0
    highlight CmpItemMenu guifg=#8289A0
    highlight PmenuSel guibg=#73daca guifg=#111111
    highlight Pmenu guibg=#2E3248
    highlight GitSignsAddNr guifg=#26A07A
    highlight GitSignsDeleteNr guifg=#E87D7D
    highlight GitSignsChangeNr guifg=#AD991F
    endfunction
augroup MyColors
    autocmd!
    autocmd ColorScheme * call MyHighlights()
augroup END]],
  true
)
