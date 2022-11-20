local status, pounce = pcall(require, "pounce")
if (not status) then return end

pounce.setup({
  accept_keys = "NTESIROAGJKDFVBYMCXWPQZ",
  accept_best_key = "<enter>",
  multi_window = true,
  debug = false,
})

vim.keymap.set('n', ',v', ':Pounce<CR>', { silent = true })
vim.keymap.set('n', 'H', ':PounceRepeat<CR>', { silent = true })
