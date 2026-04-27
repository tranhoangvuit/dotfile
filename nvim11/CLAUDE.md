# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Codebase Overview

This is a modern Neovim configuration using Lua and the lazy.nvim plugin manager. The configuration emphasizes modularity, AI integration, and developer productivity.

## Architecture & Structure

### Core Configuration Loading Flow
1. `init.lua` → loads `lua/config/lazy.lua`
2. `config/lazy.lua` → bootstraps lazy.nvim and loads:
   - `config.options` (vim settings)
   - `config.keymaps` (key mappings)
   - `config.autocmds` (auto commands)
   - All plugins from `lua/plugins/` directory

### Module Organization
- **`lua/config/`**: Core Neovim configuration (options, keymaps, autocmds, lazy setup)
- **`lua/plugins/`**: Individual plugin configurations (one file per plugin/feature)
- Each plugin module returns a lazy.nvim specification table

## Key Development Commands

### Plugin Management
- Open lazy.nvim interface: `:Lazy`
- Update plugins: `:Lazy update`
- Sync plugins with lockfile: `:Lazy restore`
- Check plugin health: `:Lazy health`

### Testing Changes
- Reload configuration: `:source $MYVIMRC` or restart Neovim
- Check for errors: `:checkhealth`
- View messages: `:messages`

### Debugging
- Check loaded modules: `:lua print(vim.inspect(package.loaded))`
- Inspect configuration: `:lua print(vim.inspect(require("config.options")))`
- View key mappings: `:map` or use which-key (`,?`)

## Plugin Configuration Patterns

When adding or modifying plugins, follow this structure:
```lua
-- lua/plugins/plugin-name.lua
return {
  "author/plugin-name",
  dependencies = { "dependency/plugin" },
  event = "VeryLazy",  -- or specific events
  opts = {
    -- configuration options
  },
  config = function(_, opts)
    require("plugin-name").setup(opts)
  end,
  keys = {
    { "<leader>xx", "<cmd>CommandName<cr>", desc = "Description" },
  },
}
```

## Key Bindings System

- **Leader key**: `,` (comma)
- **Local leader**: `\` (backslash)
- **Snacks.nvim** manages most utility keybindings (see `lua/plugins/opencode.lua`)
- Plugin-specific bindings are defined in their respective configuration files

### Recent Key Binding Updates
- **Harpoon**: Added with `<leader>ah` (add file), `<leader>h` (toggle menu), `<C-1>` through `<C-5>` (quick select)
- **OpenCode**: AI assistant with `<leader>oa` (ask), `<leader>ot` (toggle), `<leader>op` (select prompt), `<leader>oe` (explain code)

## AI Integration Points

The configuration includes multiple AI systems:
- **blink.cmp**: Integrates with Codeium for AI completions
- **opencode.nvim**: AI code assistant with various prompt commands
- **windsurf.nvim**: Codeium integration for AI suggestions

When modifying AI features, check compatibility between these systems.

## Important Configuration Details

### File Management
- **Oil.nvim** is the primary file manager (bound to `-`)
- **Snacks picker** provides fuzzy finding and grep functionality
- **Harpoon**: Quick file navigation and bookmarking system for frequently used files

### Color Scheme
- **Kanagawa** theme with transparency enabled
- Custom markdown syntax highlighting configured
- Compilation happens via `:KanagawaCompile` when modified

### Completion System
- **blink.cmp** is the completion engine
- Sources: LSP, path, buffer, snippets, Codeium
- Configuration in `lua/plugins/blink-cmp.lua`

## Common Modifications

### Adding a new plugin
1. Create a new file in `lua/plugins/plugin-name.lua`
2. Follow the plugin configuration pattern above
3. Restart Neovim or run `:Lazy` to install

### Modifying keybindings
- Global keymaps: Edit `lua/config/keymaps.lua`
- Plugin-specific: Edit the plugin's configuration file
- Snacks.nvim utilities: Modify the keys table in `lua/plugins/snacks.nvim`

### Changing vim options
Edit `lua/config/options.lua` and restart Neovim

## Dependencies & Requirements

- Neovim >= 0.9.0 (for lazy.nvim and modern plugins)
- Git (for plugin management)
- A Nerd Font (for icons in various plugins)
- ripgrep (for Snacks grep functionality)
- fd (optional, for better file finding)