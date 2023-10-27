return {
  'nvim-telescope/telescope.nvim',
  branch = '0.1.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
    'nvim-telescope/telescope-live-grep-args.nvim',
  },
  config = function()
    local actions = require('telescope.actions')
    local builtin = require("telescope.builtin")

    local function telescope_buffer_dir()
      return vim.fn.expand('%:p:h')
    end

    local fb_actions = require "telescope".extensions.file_browser.actions

    require('telescope').setup({
      defaults = {
        mappings = {
          n = {
            ["q"] = actions.close
          },
        },
      },
      extensions = {
        file_browser = {
          theme = "dropdown",
          -- disables netrw and use telescope-file-browser in its place
          hijack_netrw = true,
          mappings = {
            -- your custom insert mode mappings
            ["i"] = {
              ["<C-w>"] = function() vim.cmd('normal vbd') end,
            },
            ["n"] = {
              -- your custom normal mode mappings
              ["N"] = fb_actions.create,
              ["h"] = fb_actions.goto_parent_dir,
              ["/"] = function()
                vim.cmd('startinsert')
              end,
              ["<C-u>"] = function(prompt_bufnr)
                for i = 1, 10 do actions.move_selection_previous(prompt_bufnr) end
              end,
              ["<C-d>"] = function(prompt_bufnr)
                for i = 1, 10 do actions.move_selection_next(prompt_bufnr) end
              end,
              ["<PageUp>"] = actions.preview_scrolling_up,
              ["<PageDown>"] = actions.preview_scrolling_down,
            },
          },
        },
      },
    })
    require('telescope').load_extension('file_browser')
    require("telescope").load_extension("live_grep_args")

    vim.keymap.set('n', ';f',
      function()
        builtin.find_files({
          no_ignore = false,
          hidden = true
        })
      end)
    vim.keymap.set('n', ';r', function()
      require("telescope").extensions.live_grep_args.live_grep_args()
    end)
    vim.keymap.set('n', '\\\\', function()
      builtin.buffers()
    end)
    vim.keymap.set('n', ';t', function()
      builtin.help_tags()
    end)
    vim.keymap.set('n', ';;', function()
      builtin.resume()
    end)
    vim.keymap.set('n', ';e', function()
      builtin.diagnostics()
    end)
    vim.keymap.set("n", "sf", function()
      require('telescope').extensions.file_browser.file_browser({
        path = "%:p:h",
        cwd = telescope_buffer_dir(),
        respect_gitignore = false,
        hidden = true,
        grouped = true,
        previewer = false,
        initial_mode = "normal",
        layout_config = { height = 40 }
      })
    end)
    local live_grep_args_shortcuts = require("telescope-live-grep-args.shortcuts")
    vim.keymap.set("n", "<leader>gc", live_grep_args_shortcuts.grep_word_under_cursor)
  end,
}
