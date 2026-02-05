# 🎯 Autocomplete & Multi-Select Guide

## Overview

This guide covers the new **Autocomplete** and **Multi-Select** features added to Arch Zsh Manager, providing modern, intuitive package selection methods.

---

## 🆕 What's New

### 1. **Autocomplete with Fuzzy Matching**
Type package names with intelligent suggestions and fuzzy search.

### 2. **Multi-Select Checkbox Menus**
Visual selection of multiple packages using arrow keys and checkboxes.

### 3. **Package List Caching**
Smart caching of available/installed packages for faster performance.

---

## 🚀 Features

### Feature 1: Single Package Autocomplete

**Use Case:** Installing or searching for a specific package

```python
package = prompt_autocomplete(
    "Enter package name",
    available_packages,
    fuzzy=True
)
```

**User Experience:**
```
Enter package name: neo█
┌─────────────────────────────┐
│ neovim                      │
│ neofetch                    │
│ neomutt                     │
└─────────────────────────────┘
```

**Features:**
- ✅ Fuzzy matching (type "nvim" → suggests "neovim")
- ✅ Tab completion
- ✅ Arrow keys to navigate suggestions
- ✅ Case-insensitive search
- ✅ Real-time filtering as you type

---

### Feature 2: Multi-Package Autocomplete

**Use Case:** Installing multiple packages at once

```python
packages = prompt_autocomplete_multi(
    "Enter package names",
    available_packages
)
```

**User Experience:**
```
Enter package names (space-separated): neovim tmux git█
(Each package gets autocomplete as you type)
```

**Features:**
- ✅ Space-separated input
- ✅ Autocomplete for each package name
- ✅ Returns list of packages
- ✅ Validates each package as you type

---

### Feature 3: Multi-Select Checkbox Menu

**Use Case:** Visually selecting multiple packages

```python
selected = prompt_checkbox(
    "Select packages to install:",
    [
        ("neovim", "Neovim - Hyperextensible text editor"),
        ("tmux", "Terminal multiplexer"),
        ("git", "Version control system"),
    ]
)
```

**User Experience:**
```
📦 Select packages to install:
❯ ◉ neovim       Hyperextensible text editor
  ◯ tmux         Terminal multiplexer
  ◉ git          Version control system
  ◯ docker       Container platform

  (Space to select, Enter to confirm)
```

**Features:**
- ✅ Visual checkbox interface
- ✅ Arrow keys to navigate
- ✅ Space to toggle selection
- ✅ Enter to confirm
- ✅ Pre-selected defaults
- ✅ Can't select invalid options

---

## 📊 Comparison: Old vs New

### Old Method (Text Input)

```
Enter package names (space-separated): _
```

**Problems:**
- ❌ Must remember exact package names
- ❌ Easy to mistype
- ❌ No discovery of available packages
- ❌ No validation until submission

### New Method (Autocomplete)

```
Enter package name: neo█
  neovim
  neofetch
  neomutt
```

**Benefits:**
- ✅ Discover packages as you type
- ✅ Fuzzy matching prevents typos
- ✅ See suggestions in real-time
- ✅ Tab to complete

### New Method (Multi-Select)

```
❯ ◉ neovim
  ◯ tmux
  ◉ git
```

**Benefits:**
- ✅ Visual selection
- ✅ See all options
- ✅ Can't select invalid options
- ✅ Easy to review before confirming

---

## 🎮 Usage Examples

### Example 1: Installing Packages with Autocomplete

```python
# Load available packages (cached)
available = get_available_packages()

# Prompt with autocomplete
packages = prompt_autocomplete_multi(
    "Enter package names",
    available
)

# Install selected packages
if packages:
    install(packages, no_confirm=False, as_deps=False)
```

**User Flow:**
1. System loads package list (cached after first load)
2. User starts typing package name
3. Autocomplete suggests matches
4. User selects with Tab or continues typing
5. Repeat for multiple packages (space-separated)
6. Press Enter to confirm

---

### Example 2: Removing Packages with Multi-Select

```python
# Load installed packages
installed = get_installed_packages()

# Create choices for checkbox
choices = [(pkg, pkg) for pkg in installed]

# Multi-select menu
packages = prompt_checkbox(
    "Select packages to remove:",
    choices
)

# Remove selected packages
if packages:
    remove(packages, no_confirm=False, recursive=False)
```

**User Flow:**
1. System shows all installed packages
2. User navigates with ↑↓ arrows
3. User presses Space to select/deselect
4. User presses Enter to confirm
5. System removes selected packages

---

### Example 3: Hybrid Approach (User Choice)

```python
# Ask user for preferred method
method = prompt_select(
    "Choose input method:",
    [
        ("multi", "Multi-select from popular packages"),
        ("auto", "Autocomplete search")
    ],
    default="multi"
)

if method == "multi":
    # Show popular packages for quick selection
    packages = prompt_checkbox(
        "Select packages to install:",
        popular_choices
    )
else:
    # Autocomplete for custom packages
    packages = prompt_autocomplete_multi(
        "Enter package names",
        available
    )
```

**Benefits:**
- Power users can use autocomplete (faster)
- New users can use multi-select (discoverable)
- Best of both worlds

---

## 🔧 Technical Implementation

### Backend Functions

#### `list_available_packages()`
```zsh
# lib/backend/package.zsh
list_available_packages() {
    # Get official packages
    official_pkgs=($(pacman -Ssq 2>/dev/null))
    
    # Get AUR packages if helper available
    aur_helper=$(detect_aur_helper)
    if [[ -n "$aur_helper" ]]; then
        aur_pkgs=($(${aur_helper} -Ssq --aur 2>/dev/null | head -1000))
    fi
    
    # Return as JSON array
    json_success "Package list retrieved" packages "$json_array"
}
```

#### `list_installed_package_names()`
```zsh
# lib/backend/package.zsh
list_installed_package_names() {
    # Get installed packages
    installed=($(pacman -Qq 2>/dev/null))
    
    # Return as JSON array
    json_success "Installed package list retrieved" packages "$json_array"
}
```

---

### UI Components

#### `prompt_autocomplete()`
```python
# ui/components.py
def prompt_autocomplete(
    message: str,
    choices: List[str],
    fuzzy: bool = True,
    default: str = "",
) -> str:
    """Single input with autocomplete and fuzzy matching"""
    completer = FuzzyCompleter(WordCompleter(choices, ignore_case=True))
    result = prompt(
        f"{message}: ",
        completer=completer,
        complete_while_typing=True,
    )
    return result.strip()
```

#### `prompt_checkbox()`
```python
# ui/components.py
def prompt_checkbox(
    message: str,
    choices: List[tuple[str, str]],
    default_selected: Optional[List[str]] = None,
) -> List[str]:
    """Multi-select checkbox menu"""
    questionary_choices = [
        questionary.Choice(title=label, value=value, checked=checked)
        for value, label in choices
    ]
    result = questionary.checkbox(
        message,
        choices=questionary_choices,
        instruction="(Space to select, Enter to confirm)",
    ).ask()
    return result or []
```

---

### Caching System

```python
# pkgman.py
_package_cache = {
    "available": None,
    "installed": None,
}

def get_available_packages(force_refresh: bool = False) -> List[str]:
    """Get available packages with caching"""
    if _package_cache["available"] is None or force_refresh:
        response = backend.list_available_packages(timeout=30)
        _package_cache["available"] = response.data.get("packages", [])
    return _package_cache["available"]
```

**Benefits:**
- First load: 2-5 seconds (fetches from system)
- Subsequent loads: Instant (from cache)
- Force refresh: Clear cache when needed (after install/remove)

---

## 🎨 Customization

### Custom Styles

The menus use a custom style matching Rich theme:

```python
custom_style = Style([
    ('qmark', 'fg:cyan bold'),           # Question mark
    ('question', 'fg:cyan bold'),         # Question text
    ('answer', 'fg:green bold'),          # Selected answer
    ('pointer', 'fg:cyan bold'),          # Pointer (►)
    ('highlighted', 'fg:cyan bold'),      # Highlighted option
    ('selected', 'fg:green'),             # Selected option
    ('instruction', 'fg:yellow'),         # Instructions
])
```

### Custom Icons

```python
questionary.checkbox(
    message,
    qmark="📦",      # Custom icon before question
    pointer="►",     # Custom pointer for current item
)
```

---

## 💡 Best Practices

### 1. Use Appropriate Method

**Use Autocomplete When:**
- User knows package names
- Small number of packages (1-5)
- Power users who prefer typing

**Use Multi-Select When:**
- User browsing options
- Many packages to choose from
- Visual discovery needed
- New users

### 2. Cache Management

```python
# Clear cache after operations that change package state
if packages:
    install(packages)
    _package_cache["installed"] = None  # Clear installed cache
    _package_cache["available"] = None  # Clear available cache
```

### 3. Error Handling

```python
# Handle case where package list can't be loaded
available = get_available_packages()
if not available:
    display_warning("Could not load package list. Use manual input.")
    packages = prompt_text("Enter package names (space-separated)")
    packages = packages.split()
```

### 4. Limit Long Lists

```python
# For very long lists, limit to first N items
if len(installed) > 50:
    choices = [(pkg, pkg) for pkg in installed[:50]]
    console.print(f"[dim]Showing first 50 of {len(installed)} packages[/dim]")
else:
    choices = [(pkg, pkg) for pkg in installed]
```

---

## 🧪 Testing

### Run Tests

```bash
# Activate virtual environment
source venv/bin/activate

# Run automated tests
python test_autocomplete.py
```

**Expected Output:**
```
✅ PASSED - Imports
✅ PASSED - Function Signatures
✅ PASSED - Backend Methods
✅ PASSED - Questionary Choice
✅ PASSED - Word Completer
✅ PASSED - Cache Helpers

Total: 6/6 tests passed
```

### Run Interactive Demo

```bash
# Run full demo
python demo_autocomplete.py
```

**Demo Includes:**
1. Single autocomplete demo
2. Multi-package autocomplete demo
3. Checkbox multi-select demo
4. Comparison between methods
5. Real-world scenario (dev environment setup)

---

## 🐛 Troubleshooting

### Issue: "Input is not a terminal"

**Problem:** Running in non-interactive mode

**Solution:** 
```bash
# Run directly in terminal, not through pipes
python pkgman.py

# Don't do this:
echo "1" | python pkgman.py  # Won't work
```

---

### Issue: Autocomplete not showing suggestions

**Problem:** Package list not loaded

**Solution:**
```python
# Force refresh package list
available = get_available_packages(force_refresh=True)
```

---

### Issue: Slow first load

**Problem:** Loading thousands of packages takes time

**Solution:**
- First load: Expected (2-5 seconds)
- Cache for subsequent loads
- Show loading spinner:
  ```python
  with console.status("[cyan]Loading packages...", spinner="dots"):
      packages = get_available_packages()
  ```

---

### Issue: Fuzzy matching too aggressive

**Problem:** Getting irrelevant suggestions

**Solution:**
```python
# Disable fuzzy matching for exact matches
package = prompt_autocomplete(
    "Enter package name",
    available,
    fuzzy=False  # Exact prefix matching only
)
```

---

## 📚 Dependencies

```txt
questionary==2.0.1          # Interactive prompts
prompt-toolkit==3.0.36      # Terminal toolkit
rich==13.7.0                # Beautiful formatting
```

Install:
```bash
pip install questionary==2.0.1 prompt-toolkit==3.0.36
```

---

## 🎯 Future Enhancements

### Planned Features

1. **Fuzzy Search in Checkbox**
   - Type to filter checkbox options
   - Narrow down large lists quickly

2. **Package Descriptions**
   - Show package descriptions in autocomplete
   - Help users choose right package

3. **Category Grouping**
   - Group packages by category (dev, media, etc.)
   - Easier browsing

4. **Search History**
   - Remember recent searches
   - Quick access to frequently used packages

5. **Dependency Preview**
   - Show dependencies in checkbox
   - See what else will be installed

---

## 📖 API Reference

### `prompt_autocomplete(message, choices, fuzzy=True, default="")`

Single input with autocomplete.

**Parameters:**
- `message` (str): Prompt message
- `choices` (List[str]): Available choices
- `fuzzy` (bool): Enable fuzzy matching (default: True)
- `default` (str): Default value (default: "")

**Returns:** str - User's input

---

### `prompt_autocomplete_multi(message, choices, separator=" ")`

Multiple inputs with autocomplete (space-separated).

**Parameters:**
- `message` (str): Prompt message
- `choices` (List[str]): Available choices
- `separator` (str): Separator for multiple values (default: " ")

**Returns:** List[str] - List of user inputs

---

### `prompt_checkbox(message, choices, default_selected=None)`

Multi-select checkbox menu.

**Parameters:**
- `message` (str): Prompt message
- `choices` (List[tuple[str, str]]): List of (value, label) tuples
- `default_selected` (Optional[List[str]]): Pre-selected values

**Returns:** List[str] - List of selected values

---

### `get_available_packages(force_refresh=False)`

Get list of available packages (cached).

**Parameters:**
- `force_refresh` (bool): Force cache refresh (default: False)

**Returns:** List[str] - Available package names

---

### `get_installed_packages(force_refresh=False)`

Get list of installed packages (cached).

**Parameters:**
- `force_refresh` (bool): Force cache refresh (default: False)

**Returns:** List[str] - Installed package names

---

## 🎓 Learn More

- [Questionary Documentation](https://github.com/tmbo/questionary)
- [Prompt Toolkit Guide](https://python-prompt-toolkit.readthedocs.io/)
- [Rich Library](https://rich.readthedocs.io/)
- [Fuzzy Matching](https://en.wikipedia.org/wiki/Approximate_string_matching)

---

## ✨ Examples Gallery

### Example: Web Dev Environment Setup

```python
# Select development tools
tools = prompt_checkbox(
    "Select web development tools:",
    [
        ("nodejs", "Node.js - JavaScript runtime"),
        ("npm", "npm - Package manager"),
        ("yarn", "Yarn - Alternative package manager"),
        ("vscode", "VS Code - Code editor"),
        ("firefox", "Firefox - Browser for testing"),
    ]
)

# Install with autocomplete for additional packages
additional = prompt_autocomplete_multi(
    "Any additional packages?",
    get_available_packages()
)

# Combine and install
all_packages = tools + additional
install(all_packages)
```

---

**Enjoy the improved package selection experience! 🚀**