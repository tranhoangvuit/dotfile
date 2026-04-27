vim.pack.add({ "https://github.com/stevearc/oil.nvim" })

require("oil").setup({
    default_file_explorer = true,
    columns = {
        "permissions",
        "size",
    },
    constrain_cursor = "name",
    watch_for_changes = true,
    view_options = {
        show_hidden = true,
    },
})

vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
