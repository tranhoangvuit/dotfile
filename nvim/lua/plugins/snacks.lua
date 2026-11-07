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
    notifier = { enabled = true },
    words = { enabled = true },
    lazygit = {
        enabled = true,
        configure = true, -- auto-sets nvim-remote preset & syncs theme
        config = {
            -- Open files selected in lazygit in the pane it was launched from,
            -- instead of the nvim-remote preset's new tab. See utils/lazygit.lua.
            os = {
                edit = require("utils.lazygit").edit_command(),
                editAtLine = require("utils.lazygit").edit_command({ at_line = true }),
            },
        },
        theme = {
            activeBorderColor = { fg = "WarningMsg", bold = true },
        },
    },
    statuscolumn = {
        enabled = true,
    },
})

-- Picker
vim.keymap.set("n", ";f", function() Snacks.picker.files() end, { desc = "Find files" })
vim.keymap.set("n", ";r", function() Snacks.picker.grep() end, { desc = "Live grep" })
vim.keymap.set("n", "\\\\", function()
    Snacks.picker.buffers({
        confirm = function(picker, item)
            picker:close()
            if not item then
                return
            end
            -- If the buffer is already shown in a window (any tab),
            -- jump to that window instead of opening it here.
            vim.schedule(function()
                for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
                    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
                        if vim.api.nvim_win_get_buf(win) == item.buf then
                            vim.api.nvim_set_current_tabpage(tab)
                            vim.api.nvim_set_current_win(win)
                            return
                        end
                    end
                end
                vim.api.nvim_set_current_buf(item.buf)
            end)
        end,
    })
end, { desc = "List buffers" })
vim.keymap.set("n", ";t", function() Snacks.picker.help() end, { desc = "Help tags" })
vim.keymap.set("n", ";;", function() Snacks.picker.resume() end, { desc = "Resume picker" })
vim.keymap.set("n", "<leader>ss", function() Snacks.picker.lsp_symbols() end, { desc = "LSP document symbols" })
vim.keymap.set("n", "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end,
    { desc = "LSP workspace symbols" })

vim.keymap.set("n", ";e", function() Snacks.picker.diagnostics() end, { desc = "Diagnostics" })
vim.keymap.set("n", ";c", function() Snacks.picker.lsp_incoming_calls() end, { desc = "LSP incoming calls" })
vim.keymap.set("n", ";n", function() Snacks.picker.notifications() end, { desc = "Notifications" })
vim.keymap.set("n", ";h", function() Snacks.picker.git_diff() end, { desc = "Git diff (hunks)" })
vim.keymap.set("n", "<leader>cI", function() Snacks.picker.lsp_config() end, { desc = "LSP info" })
vim.keymap.set("n", "<leader>cR", function() Snacks.rename.rename_file() end, { desc = "Rename file" })

-- Jump between references of the word under cursor
vim.keymap.set({ "n", "t" }, "]]", function() Snacks.words.jump(vim.v.count1) end, { desc = "Next reference" })
vim.keymap.set({ "n", "t" }, "[[", function() Snacks.words.jump(-vim.v.count1) end, { desc = "Prev reference" })

-- Lazygit (files opened from lazygit land in the launching window)
vim.keymap.set("n", "<leader>lg", function() require("utils.lazygit").open() end, { desc = "Lazygit" })
vim.keymap.set("n", ";g", function() require("utils.lazygit").open() end, { desc = "Lazygit" })
