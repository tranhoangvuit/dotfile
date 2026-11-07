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
  init.lua               -- loads options, keymaps, autocmds, commands, workarounds
  options.lua            -- vim.opt settings (+ ui2 floating cmdline/messages)
  keymaps.lua            -- global keybindings
  autocmds.lua
  commands.lua           -- :ToggleFormatter
  workarounds.lua        -- temporary upstream bug workarounds
lua/plugins/
  init.lua               -- requires each plugin module
  <plugin>.lua           -- one file per plugin
lua/utils/               -- icons, lualine/tabline components, editor helpers, lazygit glue
after/lsp/<server>.lua   -- per-server LSP settings (lua_ls, vtsls, cssls, oxlint)
```

Parts adapted from [craftzdog/dotfiles](https://github.com/craftzdog/dotfiles/tree/master/dot_config/nvim).

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
| gitsigns     | Git signs, blame, hunks + gitlinker permalinks |
| lualine      | Statusline (+ custom tabline)      |
| incline      | Floating filename per window       |
| tiny-cmdline | Floating cmdline                   |
| mini.pairs   | Auto pairs                         |
| todo-comments| Highlight / search TODOs           |
| highlight-colors | Inline color previews          |

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

### LSP / code

| Key          | Action                                 |
|--------------|----------------------------------------|
| `gd` `gD` `gy` `gr` | Definition / declaration / type / references (picker) |
| `gI`         | Source definition (vtsls) / implementation |
| `gK`, `<C-k>` (insert) | Signature help               |
| `<C-j>`      | Next diagnostic                        |
| `<leader>ca` | Code action                            |
| `<leader>rn` | Rename symbol                          |
| `<leader>f`  | Format (conform; also formats on save) |
| `<leader>i`  | Toggle inlay hints                     |
| `<leader>cI` | LSP info                               |
| `<leader>cR` | Rename file                            |
| `]]` / `[[`  | Next / prev reference of word          |
| `:ToggleFormatter` | Disable/enable format-on-save for buffer |

### Pickers

| Key   | Action               |
|-------|----------------------|
| `;f` `;r` `;t` `;;` | Files / grep / help / resume |
| `\\`  | Buffers (jumps to existing window) |
| `;e` `;c` `;n` `;h` `;T` | Diagnostics / incoming calls / notifications / git hunks / TODOs |
| `;g`  | Lazygit (opened files land in launching window) |

### Git

| Key          | Action                        |
|--------------|-------------------------------|
| `]c` / `[c`  | Next / prev hunk              |
| `<leader>gl` | Blame line                    |
| `<leader>gB` | Blame buffer                  |
| `<leader>gd` | Preview hunk inline           |
| `<leader>gh` | Stage hunk                    |
| `<leader>gs` | Toggle stage buffer           |
| `<leader>go` | Open file at blamed commit    |
| `<leader>gy` / `gY` | Copy / open permalink  |
| `<leader>ru` `rm` `rh` | CodeDiff unstaged / main / HEAD~1 |
| `<leader>rf` / `rF` | File / repo history (CodeDiff) |

### Misc

| Key          | Action                       |
|--------------|------------------------------|
| `gl`         | Open diagnostic float        |
| `sf`         | Oil float with preview       |
| `x`          | Delete char without yanking  |
| `<leader>p` / `P` | Paste last yank (`"0`)  |
| `<leader>o` / `O` | New line without comment continuation |
| `<leader>cy` / `cY` | Copy relative / absolute path with line |
| `<leader>cc` (visual) | Copy selection as markdown codeblock |
| `<leader>j`  | package.json in float        |
| `<leader>bd` | Delete hidden buffers        |
| `<leader>tt` | Open terminal in vsplit      |
| `<Esc>`      | Exit terminal mode           |

## Notes

- `clipboard = unnamedplus` — yanks go to system clipboard by default.
- `expandtab`, `shiftwidth = 4`.
- Undo persisted between sessions (`undofile`).
- Plugin lock pinned in `nvim-pack-lock.json`.
