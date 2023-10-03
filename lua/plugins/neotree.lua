return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
    "MunifTanjim/nui.nvim",
  },
  config = function()
    -- Unless you are still migrating, remove the deprecated commands from v1.x
    vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])
    vim.keymap.set('n', '<C-e>', '<Cmd>Neotree toggle<CR>')
    require('neo-tree').setup({
      filesystem = {
        follow_current_file = {
          enable = true,
          leave_dirs_open = false,
        }
      },
      buffers = {
        follow_current_file = {
          enabled = true,          -- This will find and focus the file in the active buffer every time
          leave_dirs_open = false, -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
        },
      }
    })
    vim.cmd([[nnoremap \ :Neotree reveal<cr>]])
  end,
}
