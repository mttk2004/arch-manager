# Project Structure

```
arch-zsh-manager/
├── bin/                      # Executables
│   └── pkgman               # Main entry point
│
├── lib/                      # Core libraries
│   ├── core/                 # Core functionalities
│   │   ├── colors.zsh        # Color & icon definitions
│   │   ├── ui.zsh            # UI components (boxes, badges, menus)
│   │   ├── utils.zsh         # Utility functions
│   │   └── detect.zsh        # System detection (AUR, flatpak)
│   │
│   ├── package/              # Package management
│   │   ├── install.zsh       # Install packages
│   │   ├── remove.zsh        # Remove packages
│   │   ├── update.zsh        # Update system
│   │   ├── search.zsh        # Search packages
│   │   └── info.zsh          # Package info
│   │
│   ├── system/               # System maintenance
│   │   ├── cache.zsh         # Cache cleaning
│   │   ├── orphan.zsh        # Orphan packages
│   │   ├── broken.zsh        # Broken packages
│   │   └── list.zsh          # List installed
│   │
│   ├── advanced/             # Advanced features
│   │   ├── downgrade.zsh     # Downgrade packages
│   │   ├── logs.zsh          # View logs
│   │   ├── mirror.zsh        # Mirror management
│   │   └── yay.zsh           # YAY installer
│   │
│   ├── font/                 # Font management
│   │   ├── menu.zsh          # Font manager menu
│   │   ├── install.zsh       # Font installation
│   │   ├── manage.zsh        # List/search/remove fonts
│   │   └── test.zsh          # Display test
│   │
│   └── devtools/             # Development tools
│       ├── menu.zsh          # Dev tools menu
│       ├── web.zsh           # Web dev (PHP, Node, Laravel)
│       ├── database.zsh      # Databases (PostgreSQL, MySQL, etc.)
│       ├── language.zsh      # Languages (Java, Python, Go, Rust)
│       └── devops.zsh        # DevOps (Docker, Git)
│
├── docs/                     # Documentation
│   ├── FONT_MANAGER_GUIDE.md
│   ├── FONT_QUICKSTART.md
│   └── DEV_TOOLS_GUIDE.md
│
├── scripts/                  # Utility scripts
│   ├── install.sh            # Installation
│   └── font-preview.sh       # Font preview
│
├── config/                   # Config (future)
│   └── pkgman.conf.example
│
├── README.md
├── CHANGELOG.md
├── LICENSE
└── .editorconfig
```

## Module Organization

### Core (`lib/core/`)
- `colors.zsh`: Color codes, icons, variables
- `ui.zsh`: UI components (create_box, badge, menu_item, etc.)
- `utils.zsh`: Utility functions (pause_prompt, etc.)
- `detect.zsh`: System detection (detect_aur_helper, has_flatpak)

### Package (`lib/package/`)
- Each file handles one main menu option
- Self-contained with minimal dependencies

### System (`lib/system/`)
- System maintenance tasks
- Independent modules

### Advanced (`lib/advanced/`)
- Advanced features
- Can depend on core modules

### Font (`lib/font/`)
- Complete font management
- Self-contained module

### DevTools (`lib/devtools/`)
- Development environment setup
- Modular by category
