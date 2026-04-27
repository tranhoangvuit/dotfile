vim.pack.add({
    "https://github.com/folke/snacks.nvim",
    "https://github.com/nvim-tree/nvim-web-devicons",
})

require("snacks").setup({
    scroll = {
        enabled = false,
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
})

-- Picker
vim.keymap.set("n", ";f", function() Snacks.picker.files() end, { desc = "Find files" })
vim.keymap.set("n", ";r", function() Snacks.picker.grep() end, { desc = "Live grep" })
vim.keymap.set("n", "\\\\", function() Snacks.picker.buffers() end, { desc = "List buffers" })
vim.keymap.set("n", ";t", function() Snacks.picker.help() end, { desc = "Help tags" })
vim.keymap.set("n", ";;", function() Snacks.picker.resume() end, { desc = "Resume picker" })
vim.keymap.set("n", "<leader>ss", function() Snacks.picker.lsp_symbols() end, { desc = "LSP document symbols" })
vim.keymap.set("n", "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end,
    { desc = "LSP workspace symbols" })

-- Lazygit
vim.keymap.set("n", "<leader>lg", function() Snacks.lazygit() end, { desc = "Lazygit" })
