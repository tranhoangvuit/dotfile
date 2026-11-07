vim.pack.add({ "https://github.com/stevearc/oil.nvim" })

require("oil").setup({
    default_file_explorer = true,
    columns = {
        "icon",
        { "permissions", highlight = "Type" },
        { "size", highlight = "String" },
        { "mtime", highlight = "Keyword" },
    },
    constrain_cursor = "name",
    watch_for_changes = true,
    keymaps = {
        ["h"] = { "actions.parent", mode = "n" },
        ["q"] = { "actions.close", mode = "n" },
    },
    view_options = {
        show_hidden = true,
    },
    float = {
        border = "rounded",
        win_options = {
            winblend = 0,
        },
        max_width = 200,
    },
    preview_win = {
        update_on_cursor_moved = true,
    },
    lsp_file_methods = {
        enabled = true,
        timeout_ms = 1000,
        autosave_changes = true,
    },
})

vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
vim.keymap.set("n", "sf", function()
    require("oil").open_float(nil, { preview = {} })
end, { desc = "Oil float with preview" })
