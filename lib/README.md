# Library Modules

This directory contains all modular components of Arch Package Manager.

## Structure

```
lib/
├── core/           # Core functionality
├── package/        # Package management
├── system/         # System maintenance
├── advanced/       # Advanced features
├── font/           # Font management
└── devtools/       # Development tools
```

## Module Loading Order

Modules are loaded in this order in `bin/pkgman`:

1. **Core modules** (required first):
   - `core/colors.zsh` - Color definitions
   - `core/ui.zsh` - UI components
   - `core/detect.zsh` - System detection
   - `core/utils.zsh` - Utility functions

2. **Feature modules**:
   - Package management modules
   - System maintenance modules
   - Advanced feature modules
   - Font management modules
   - Development tools modules

## Creating New Modules

When creating a new module:

1. Place it in the appropriate category directory
2. Add function prefix to avoid naming conflicts
3. Document all public functions
4. Source it in `bin/pkgman`

Example module template:

```zsh
#!/usr/bin/env zsh

# =============================================================================
# Module Name - Brief Description
# =============================================================================

# Function documentation
function_name() {
    local param=$1
    # Implementation
}
```
