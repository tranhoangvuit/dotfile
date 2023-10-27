-- Install lazy - package manager
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- Plugins
require('lazy').setup({
  -- Custom plugins
  { import = 'plugins' },

  -- Git
  'lewis6991/gitsigns.nvim',
  -- Copilot
  'github/copilot.vim',
  -- Common utilities
  'nvim-lua/plenary.nvim',
  -- Useful plugin to show you pending keybinds.
  { 'folke/which-key.nvim', opts = {} },
  {
    -- Theme inspired by Atom
    'rebelot/kanagawa.nvim',
    priority = 1000,
    config = function()
      vim.cmd.colorscheme 'kanagawa'
    end,
  },
  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim',                     opts = {} },
  { 'nvim-telescope/telescope-file-browser.nvim' },
})
vim.g.copilot_no_tab_map = true
vim.g.copilot_assume_mapped = true
