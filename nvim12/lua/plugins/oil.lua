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
