-- Plugin declarations
vim.pack.add({
    { src = "https://github.com/mason-org/mason.nvim" },
    { src = "https://github.com/stevearc/oil.nvim" },
    { src = "https://github.com/rebelot/kanagawa.nvim" },
    {
        src = "https://github.com/saghen/blink.cmp",
        version = vim.version.range("^1"),
    },
    { src = "https://github.com/folke/which-key.nvim" },
    { src = "https://github.com/nvim-lua/plenary.nvim" },
    { src = "https://github.com/folke/snacks.nvim" },
    { src = "https://github.com/stevearc/conform.nvim" },
    { src = "https://github.com/folke/sidekick.nvim" },
    { src = "https://github.com/folke/trouble.nvim" },
    { src = "https://github.com/j-hui/fidget.nvim" },
})

-- Add Mason binaries to PATH
vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. vim.env.PATH
