vim.pack.add({ "https://github.com/folke/sidekick.nvim" })

require("sidekick").setup({})

vim.keymap.set({ "n", "v" }, "<leader>a", "", { desc = "+ai" })
vim.keymap.set("n", "<leader>aa", function() require("sidekick.cli").toggle() end, { desc = "Sidekick Toggle" })
vim.keymap.set({ "x", "n" }, "<leader>at", function() require("sidekick.cli").send({ msg = "{this}" }) end,
    { desc = "Send This" })
vim.keymap.set("x", "<leader>av", function() require("sidekick.cli").send({ msg = "{selection}" }) end,
    { desc = "Send Visual Selection" })
vim.keymap.set({ "n", "x", "i", "t" }, "<c-.>", function() require("sidekick.cli").focus() end,
    { desc = "Sidekick Switch Focus" })
