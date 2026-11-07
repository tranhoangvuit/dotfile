local opts = { noremap = true, silent = true }

vim.keymap.set("n", "gl", function()
  vim.diagnostic.open_float()
end, { desc = "Open Diagnostics in Float" })

-- Yank to system clipboard
vim.keymap.set("n", "<leader>y", '"+y')
vim.keymap.set("v", "<leader>y", '"+y')
vim.keymap.set("n", "<leader>Y", '"+Y')

-- Copy current file path to system clipboard
vim.keymap.set("n", "<leader>cp", function()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg("+", path)
  vim.notify("Copied: " .. path)
end, { desc = "Copy absolute file path" })

vim.keymap.set("n", "<leader>cr", function()
  local path = vim.fn.fnamemodify(vim.fn.expand("%"), ":.")
  vim.fn.setreg("+", path)
  vim.notify("Copied: " .. path)
end, { desc = "Copy relative file path" })

vim.keymap.set("n", "<leader>cn", function()
  local name = vim.fn.expand("%:t")
  vim.fn.setreg("+", name)
  vim.notify("Copied: " .. name)
end, { desc = "Copy file name" })

-- Split window
vim.keymap.set("n", "ss", ":split<Return>", opts)
vim.keymap.set("n", "sv", ":vsplit<Return>", opts)

-- Move window
vim.keymap.set("n", "sh", "<C-w>h")
vim.keymap.set("n", "sk", "<C-w>k")
vim.keymap.set("n", "sj", "<C-w>j")
vim.keymap.set("n", "sl", "<C-w>l")

-- Resize window
vim.keymap.set("n", "<C-w><left>", "<C-w><")
vim.keymap.set("n", "<C-w><right>", "<C-w>>")
vim.keymap.set("n", "<C-w><up>", "<C-w>+")
vim.keymap.set("n", "<C-w><down>", "<C-w>-")

-- tabs
vim.keymap.set("n", "<Leader>te", "<cmd>tabnew<CR>")
vim.keymap.set("n", "<Leader>tn", "<cmd>tabn<CR>")
vim.keymap.set("n", "<Leader>tp", "<cmd>tabp<CR>")

-- Exit terminal with Esc
vim.keymap.set("t", "<Esc>", "<C-\\><C-N>")

-- Open small terminal
vim.keymap.set("n", "<leader>tt", function()
  vim.cmd.vnew()
  vim.cmd.term()
  vim.cmd.wincmd("J")
  vim.api.nvim_win_set_height(0, 15)
end)

-- Do things without updating the registers
vim.keymap.set("n", "x", '"_x')
vim.keymap.set("n", "<leader>p", '"0p', { desc = "Paste last yank" })
vim.keymap.set("n", "<leader>P", '"0P', { desc = "Paste last yank before" })
vim.keymap.set("v", "<leader>p", '"0p', { desc = "Paste last yank" })

-- New line without comment continuation
vim.keymap.set("n", "<leader>o", "o<Esc>^Da", opts)
vim.keymap.set("n", "<leader>O", "O<Esc>^Da", opts)

-- Toggle inlay hints
vim.keymap.set("n", "<leader>i", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), { bufnr = 0 })
end, { desc = "Toggle inlay hints" })

-- Copy file path with line number
vim.keymap.set("n", "<leader>cy", function()
  require("utils.editor").yank_relative_path_with_line()
end, { desc = "Copy relative path with line" })

vim.keymap.set("n", "<leader>cY", function()
  require("utils.editor").yank_absolute_path_with_line()
end, { desc = "Copy absolute path with line" })

vim.keymap.set("v", "<leader>cc", ":<C-u>lua require('utils.editor').copy_as_codeblock()<CR>",
  { desc = "Copy as markdown codeblock" })

vim.keymap.set("n", "<leader>j", function()
  require("utils.editor").open_package_json()
end, { desc = "Open package.json in floating window" })

vim.keymap.set("n", "<leader>bd", function()
  require("utils.editor").delete_hidden_buffers()
end, { desc = "Delete hidden buffers" })
