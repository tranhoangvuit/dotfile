return {
  'akinsho/toggleterm.nvim',
  version = "*",
  opts = {},
  config = function()
    require('toggleterm').setup({
      size = 30,
      open_mapping = [[<c-\>]],
    })
  end,
}
