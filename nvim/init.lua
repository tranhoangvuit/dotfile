if vim.loader then
	vim.loader.enable()
end

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Load plugins first (vim.pack.add declarations)
require("config")
require("plugins")
