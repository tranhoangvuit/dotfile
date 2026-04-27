vim.pack.add({
    "https://github.com/kdheepak/lazygit.nvim"
})

vim.keymap.set('n', '<leader>gg', '<cmd>LazyGit<cr>', { desc = 'Lazygit' })
vim.keymap.set('n', '<leader>gb', function() vim.ui.open(vim.fn.systemlist('git remote get-url origin')[1]) end,
	{ desc = 'Open git remote' })
