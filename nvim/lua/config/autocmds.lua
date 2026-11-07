local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Highlight yanked text
local highlight_group = augroup('YankHighlight', { clear = true })
autocmd('TextYankPost', {
    pattern = '*',
    callback = function()
        vim.hl.on_yank({ timeout = 170 })
    end,
    group = highlight_group,
})

-- Highlight the current line only in the active window
local cursorline_group = augroup('CursorLine', { clear = true })
autocmd({ 'VimEnter', 'WinEnter', 'BufWinEnter' }, {
    group = cursorline_group,
    command = 'setlocal cursorline',
})
autocmd('WinLeave', {
    group = cursorline_group,
    command = 'setlocal nocursorline',
})

-- Custom filetypes
vim.filetype.add({
    extension = {
        mjml = 'html',
    },
})
