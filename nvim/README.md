# nvim

Personal Neovim config. Uses built-in `vim.pack` for plugin management — no Lazy/Packer.

## Install

Symlink to `~/.config/nvim`:

```bash
ln -s ~/Projects/dotfile/nvim ~/.config/nvim
```

Requires Neovim 0.12+ (for `vim.pack`).

## Layout

```
init.lua                 -- entry, sets leader = <Space>
lua/config/
  init.lua               -- loads options, keymaps, autocmds
  options.lua            -- vim.opt settings
  keymaps.lua            -- global keybindings
  autocmds.lua
lua/plugins/
  init.lua               -- requires each plugin module
  <plugin>.lua           -- one file per plugin
```

## Plugins

| Plugin       | Purpose                            |
|--------------|------------------------------------|
| treesitter   | Syntax / parsing                   |
| blink        | Completion                         |
| conform      | Formatter                          |
| lsp          | LSP setup                          |
| oil          | File explorer (buffer-as-dir)      |
| snacks       | Misc UI utilities                  |
| trouble      | Diagnostics list                   |
| which-key    | Keymap hints                       |
| kanagawa     | Colorscheme                        |
| neoscroll    | Smooth scroll                      |
| codediff     | Diff view                          |
| sidekick     | AI assist                          |
| lazygit      | Git TUI integration                |

## Keymaps

Leader is `<Space>`.

### Clipboard

| Key           | Action                          |
|---------------|---------------------------------|
| `<leader>y`   | Yank to system clipboard        |
| `<leader>Y`   | Yank line to system clipboard   |
| `<leader>cp`  | Copy absolute file path         |
| `<leader>cr`  | Copy relative file path         |
| `<leader>cn`  | Copy file name                  |

### Windows

| Key        | Action                |
|------------|-----------------------|
| `ss`       | Horizontal split      |
| `sv`       | Vertical split        |
| `sh/j/k/l` | Move between splits   |
| `<C-w>` + arrows | Resize split    |

### Tabs

| Key          | Action      |
|--------------|-------------|
| `<leader>te` | New tab     |
| `<leader>tn` | Next tab    |
| `<leader>tp` | Prev tab    |

### Misc

| Key          | Action                       |
|--------------|------------------------------|
| `gl`         | Open diagnostic float        |
| `<leader>tt` | Open terminal in vsplit      |
| `<Esc>`      | Exit terminal mode           |

## Notes

- `clipboard = unnamedplus` — yanks go to system clipboard by default.
- `expandtab`, `shiftwidth = 4`.
- Undo persisted between sessions (`undofile`).
- Plugin lock pinned in `nvim-pack-lock.json`.
