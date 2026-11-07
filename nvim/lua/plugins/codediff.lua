vim.pack.add({
    "https://github.com/esmuellert/codediff.nvim"
})

require("codediff").setup({
    explorer = {
        width = 50,
        auto_open_on_cursor = true,
        view_mode = "tree", -- "list" or "tree"
        line_stats = {
            enabled = true,
        },
    },
    diff = {
        compact = true,
        compact_context_lines = 8,
        compact_sync_folds = true, -- open/close folds in both panes together
    },
})

vim.keymap.set('n', '<leader>ru', '<cmd>CodeDiff<cr>', { desc = 'Code diff not staged' })
vim.keymap.set('n', '<leader>rm', '<cmd>CodeDiff main<cr>', { desc = 'Code diff main' })
vim.keymap.set('n', '<leader>rh', '<cmd>CodeDiff HEAD~1<cr>', { desc = 'Code diff previous commit' })
vim.keymap.set('n', '<leader>rf', '<cmd>CodeDiff history %<cr>', { desc = 'File history (current file)' })
vim.keymap.set('n', '<leader>rF', '<cmd>CodeDiff history<cr>', { desc = 'File history (repo)' })
