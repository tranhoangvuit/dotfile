return {
    "folke/snacks.nvim",
    opts = {
        indent = {
            priority = 1,
            enabled = true, -- enable indent guides
            char = "│",
        },
        lazygit = {
            enabled = true,
        },
    },
    keys = {
        -- Others
        { "<leader>lg", function() Snacks.lazygit() end, desc = "Lazygit" },
    }
}
