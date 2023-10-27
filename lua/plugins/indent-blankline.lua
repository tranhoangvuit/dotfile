return {
  -- Add indentation guides even on blank lines
  'lukas-reineke/indent-blankline.nvim',
  -- Enable `lukas-reineke/indent-blankline.nvim`
  -- See `:help indent_blankline.txt`
  main = 'ibl',
  config = function()
    require('ibl').setup {
      indent = { char = "┊" },
      whitespace = {
        highlight = {
          "Whitespace",
        },
        remove_blankline_trail = false,
      },
      scope = { enabled = false },
    }
  end,
}
