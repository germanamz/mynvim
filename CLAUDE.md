# My neovim confighis
This project is my neovim config

## Project Structure

```
~/.config/nvim/
├── init.lua                    # Bootstrap file - loads all modules
├── lua/
│   ├── config/                 # Core editor configuration
│   │   ├── init.lua           # Config module loader
│   │   ├── options.lua        # Vim options and settings
│   │   ├── keymaps.lua        # Global keymaps
│   │   └── autocmds.lua       # Autocommands
│   ├── plugins/               # Plugin-specific configurations  
│   │   ├── init.lua           # Plugin manager and plugin list
│   │   ├── lsp.lua            # LSP configurations
│   │   ├── completion.lua     # nvim-cmp setup
│   │   ├── telescope.lua      # Telescope configuration
│   │   ├── treesitter.lua     # Treesitter and text objects
│   │   ├── git.lua            # Git-related plugins
│   │   ├── ui.lua             # UI plugins (nvim-tree, lualine)
│   │   ├── formatting.lua     # Formatting and linting
│   │   └── debugging.lua      # DAP configuration
│   ├── core/                  # Core functionality
│   │   ├── init.lua           # Core module loader  
│   │   ├── theme.lua          # Colorscheme and highlights
│   │   └── tabline.lua        # Custom tabline functionality
│   ├── keybind_docs.lua       # Custom keybinding documentation system
│   ├── pkgmgr.lua             # Package management utilities
│   └── util/
│       └── path.lua           # Path utility functions
└── improvements.txt           # Documentation of improvements made
```

### Module Organization
- **config/**: Core Neovim settings (options, keymaps, autocommands)
- **plugins/**: Plugin configurations organized by functionality
- **core/**: Essential functionality (theme, UI components)
- **Custom utilities**: pkgmgr.lua, keybind_docs.lua for enhanced workflow

### Key Design Principles
- Modular structure for easy maintenance
- Lazy loading for optimal performance
- Consistent patterns across all plugin configurations
- Custom utilities for project-aware tooling

## Rules for changes

### Code Organization
* **Maintain modular structure**: Add new functionality to appropriate modules (config/, plugins/, core/)
* **Follow existing patterns**: Use the same setup patterns and naming conventions as existing modules
* **Create new modules**: If adding substantial new functionality, create dedicated module files rather than expanding existing ones

### Keybindings
* **Document all keybindings**: When a new keybinding is added/created it should be added to the auto-documentation system
* **Check for conflicts**: Verify new keybindings don't conflict with existing ones across all modules
* **Consider navigation plugins**: When configuring buffers or similar, account for both nvim-tree and Telescope workflows

### Plugin Management
* **Update plugin list**: New plugins must be added to `lua/plugins/init.lua` with proper lazy loading configuration
* **Modular configs**: Each plugin should have its configuration in the appropriate module file
* **Dependencies**: Ensure plugin dependencies are properly declared in the lazy.nvim spec

### LSP and Tools
* **Use pkgmgr utilities**: Leverage `pkgmgr.lua` functions for project-aware tool detection
* **Local tool preference**: Always prefer local project tools over global ones using `pkgmgr.prefer_local()`
* **Graceful fallbacks**: Ensure configurations work even when tools/LSPs are not available

### Testing and Validation
* **Test module loading**: New modules should load without errors in isolation
* **Verify startup**: Changes should not break Neovim startup or cause performance issues
* **Check health**: Use `:checkhealth` to verify new configurations work properly

### Documentation
* **Update CLAUDE.md**: Document significant architectural changes in this file
* **Inline comments**: Add comments for complex logic or non-obvious configurations
* **Keep improvements.txt updated**: Document optimizations and technical debt addressed

