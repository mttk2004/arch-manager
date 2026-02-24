"""
UI Components - Reusable UI widgets and utilities using Rich library

This module provides reusable components for building beautiful terminal interfaces:
- Tables for displaying data
- Panels for grouping content
- Progress bars for long operations
- Status messages (success, error, warning, info)
- Prompts and confirmations
"""

from __future__ import annotations

import logging
from typing import Any, Callable, List, Optional

import questionary
from prompt_toolkit.completion import FuzzyCompleter, WordCompleter
from prompt_toolkit.shortcuts import prompt
from questionary import Style
from rich.columns import Columns
from rich.console import Console
from rich.panel import Panel
from rich.progress import (
    BarColumn,
    Progress,
    SpinnerColumn,
    TaskID,
    TextColumn,
    TimeElapsedColumn,
)
from rich.prompt import Confirm, Prompt
from rich.rule import Rule
from rich.table import Table
from rich.text import Text
from rich.tree import Tree

from ui.theme import APP_BANNER, APP_BANNER_SMALL, Colors, Icons, MenuCategory, MENU_ITEMS

# Global console instance
console = Console()

# Logger for this module
logger = logging.getLogger(__name__)


# =============================================================================
# Display Functions
# =============================================================================


def display_success(message: str, data: Optional[dict[str, Any]] = None) -> None:
    """
    Display success message with optional data

    Args:
        message: Success message
        data: Optional data dictionary to display
    """
    panel = Panel(
        Text(message, style=Colors.SUCCESS),
        title=f"{Icons.SUCCESS} Success",
        title_align="left",
        border_style=Colors.BORDER_SUCCESS,
        padding=(0, 1),
    )
    console.print(panel)

    if data:
        console.print(data, style=Colors.TEXT_DIM)


def display_error(message: str, error_code: Optional[str] = None) -> None:
    """
    Display error message

    Args:
        message: Error message
        error_code: Optional error code
    """
    text = Text(message, style=Colors.ERROR)
    if error_code:
        text.append(f" (Code: {error_code})", style="dim red")

    panel = Panel(
        text,
        title=f"{Icons.ERROR} Error",
        title_align="left",
        border_style=Colors.BORDER_ERROR,
        padding=(0, 1),
    )
    console.print(panel)


def display_warning(message: str) -> None:
    """
    Display warning message

    Args:
        message: Warning message
    """
    panel = Panel(
        Text(message, style=Colors.WARNING),
        title=f"{Icons.WARNING} Warning",
        title_align="left",
        border_style=Colors.BORDER_WARNING,
        padding=(0, 1),
    )
    console.print(panel)


def display_info(message: str) -> None:
    """
    Display info message

    Args:
        message: Info message
    """
    panel = Panel(
        Text(message, style=Colors.INFO),
        title=f"{Icons.INFO} Info",
        title_align="left",
        border_style=Colors.BORDER_INFO,
        padding=(0, 1),
    )
    console.print(panel)


# =============================================================================
# Table Components
# =============================================================================


def create_table(
    title: str,
    columns: list[tuple[str, str]],
    rows: list[list[str]],
    show_header: bool = True,
    show_lines: bool = False,
) -> Table:
    """
    Create a Rich table

    Args:
        title: Table title
        columns: List of (name, style) tuples for columns
        rows: List of row data
        show_header: Whether to show table header
        show_lines: Whether to show lines between rows

    Returns:
        Rich Table object

    Example:
        >>> table = create_table(
        ...     "Packages",
        ...     [("Name", "cyan"), ("Version", "green")],
        ...     [["neovim", "0.9.5"], ["tmux", "3.3a"]]
        ... )
        >>> console.print(table)
    """
    table = Table(title=title, show_header=show_header, show_lines=show_lines)

    # Add columns
    for col_name, col_style in columns:
        table.add_column(col_name, style=col_style)

    # Add rows
    for row in rows:
        table.add_row(*row)

    return table


def create_package_table(packages: list[dict[str, str]]) -> Table:
    """
    Create a table for displaying packages

    Args:
        packages: List of package dictionaries with name, version, size

    Returns:
        Rich Table object
    """
    table = Table(title="📦 Packages", show_header=True, header_style="bold magenta")

    table.add_column("#", style="dim", width=4)
    table.add_column("Name", style="cyan", no_wrap=True)
    table.add_column("Version", style="green")
    table.add_column("Size", style="yellow", justify="right")
    table.add_column("Status", style="blue")

    for idx, pkg in enumerate(packages, start=1):
        table.add_row(
            str(idx),
            pkg.get("name", "N/A"),
            pkg.get("version", "N/A"),
            pkg.get("size", "N/A"),
            pkg.get("status", "installed"),
        )

    return table


def create_search_results_table(results: list[str], aur_results: list[str]) -> Table:
    """
    Create a table for package search results

    Args:
        results: Official repository results
        aur_results: AUR results

    Returns:
        Rich Table object
    """
    table = Table(
        title="🔍 Search Results", show_header=True, header_style="bold magenta"
    )

    table.add_column("#", style="dim", width=4)
    table.add_column("Package", style="cyan")
    table.add_column("Repository", style="green")

    idx = 1
    for pkg in results:
        table.add_row(str(idx), pkg, "official")
        idx += 1

    for pkg in aur_results:
        table.add_row(str(idx), pkg, "[bold yellow]AUR[/bold yellow]")
        idx += 1

    return table


# =============================================================================
# Panel Components
# =============================================================================


def create_panel(
    content: str,
    title: str = "",
    border_style: str = "blue",
    padding: tuple[int, int] = (1, 2),
) -> Panel:
    """
    Create a Rich panel

    Args:
        content: Panel content
        title: Panel title
        border_style: Border color style
        padding: Padding (vertical, horizontal)

    Returns:
        Rich Panel object
    """
    return Panel(
        content,
        title=title,
        border_style=border_style,
        padding=padding,
    )


def create_header(title: str, subtitle: str = "") -> Panel:
    """
    Create application header with styled banner

    Args:
        title: Main title
        subtitle: Optional subtitle

    Returns:
        Rich Panel object
    """
    content = Text()
    content.append(title, style=Colors.PRIMARY_BOLD)
    if subtitle:
        content.append("\n")
        content.append(subtitle, style=Colors.TEXT_DIM)

    return Panel(
        content,
        border_style=Colors.HEADER_BORDER,
        padding=(1, 2),
    )


def create_app_header() -> Text:
    """
    Create the main application ASCII art header with gradient coloring.

    Returns:
        Rich Text object with the styled ASCII art banner
    """
    width = console.width
    if width < 60:
        banner = APP_BANNER_SMALL
    else:
        banner = APP_BANNER

    text = Text()
    lines = banner.split("\n")
    gradient = [
        "bright_blue",
        "cyan",
        "bright_cyan",
        "cyan",
        "bright_blue",
        "blue",
        "bright_blue",
        "cyan",
        "bright_cyan",
    ]
    for i, line in enumerate(lines):
        color = gradient[i % len(gradient)]
        text.append(line + "\n", style=color)

    text.append("    Hybrid Python/Zsh Package Manager for Arch Linux\n", style=Colors.TEXT_DIM)
    return text


def create_menu_panel(items: list[tuple[str, str]]) -> Panel:
    """
    Create a menu panel

    Args:
        items: List of (key, description) tuples

    Returns:
        Rich Panel object
    """
    content = Text()

    for key, description in items:
        content.append(f"  [{key}] ", style=Colors.MENU_KEY)
        content.append(f"{description}\n", style=Colors.MENU_TEXT)

    return Panel(
        content,
        title=f"{Icons.LIST} Menu",
        border_style=Colors.PRIMARY,
        padding=(1, 2),
    )


def create_grouped_menu() -> Panel:
    """
    Create a grouped menu panel with categorized items and section dividers.

    Returns:
        Rich Panel with grouped menu items
    """
    content = Text()

    section_icons = {
        MenuCategory.PACKAGE_MANAGEMENT: Icons.SECTION_PKG,
        MenuCategory.SYSTEM_MAINTENANCE: Icons.SECTION_SYS,
        MenuCategory.OTHER: Icons.SECTION_OTHER,
    }

    for idx, (category, items) in enumerate(MENU_ITEMS.items()):
        icon = section_icons.get(category, "")
        # Section header
        content.append(f"\n  {icon} {category}\n", style=Colors.SECTION)
        content.append(f"  {'─' * 40}\n", style=Colors.SECTION_DIM)

        for key, label, _description in items:
            content.append(f"    [{key}] ", style=Colors.MENU_KEY)
            content.append(f"{label}\n", style=Colors.MENU_TEXT)

    return Panel(
        content,
        title=f"{Icons.ROCKET} Arch Manager",
        subtitle="[dim]↑↓ Navigate • Enter Select • 0-9 Shortcut[/dim]",
        border_style=Colors.HEADER_BORDER,
        padding=(0, 2),
    )


# =============================================================================
# Progress Components
# =============================================================================


def show_progress(
    description: str = "Working...",
    total: Optional[int] = None,
) -> tuple[Progress, TaskID]:
    """
    Create and start a progress bar

    Args:
        description: Progress description
        total: Total steps (None for indeterminate)

    Returns:
        Tuple of (Progress object, TaskID)

    Example:
        >>> progress, task = show_progress("Installing packages", total=3)
        >>> progress.start()
        >>> for i in range(3):
        ...     progress.update(task, advance=1)
        >>> progress.stop()
    """
    progress = Progress(
        SpinnerColumn(),
        TextColumn("[progress.description]{task.description}"),
        BarColumn(),
        TextColumn("[progress.percentage]{task.percentage:>3.0f}%"),
        TimeElapsedColumn(),
        console=console,
    )

    task = progress.add_task(description, total=total)
    return progress, task


# =============================================================================
# Prompt Components
# =============================================================================


def prompt_text(
    message: str,
    default: str = "",
    password: bool = False,
) -> str:
    """
    Prompt user for text input

    Args:
        message: Prompt message
        default: Default value
        password: Whether to hide input

    Returns:
        User input string
    """
    return Prompt.ask(message, default=default, password=password, console=console)


def prompt_confirm(message: str, default: bool = False) -> bool:
    """
    Prompt user for yes/no confirmation

    Args:
        message: Confirmation message
        default: Default value

    Returns:
        True if confirmed, False otherwise
    """
    return Confirm.ask(message, default=default, console=console)


def prompt_choice(
    message: str,
    choices: list[str],
    default: Optional[str] = None,
) -> str:
    """
    Prompt user to choose from a list

    Args:
        message: Prompt message
        choices: List of valid choices
        default: Default choice

    Returns:
        Selected choice
    """
    return Prompt.ask(
        message,
        choices=choices,
        default=default,
        console=console,
    )


def prompt_select(
    message: str,
    choices: List[tuple[str, str]],
    default: Optional[str] = None,
    use_shortcuts: bool = False,
) -> str:
    """
    Interactive selection menu with arrow key navigation

    Args:
        message: Prompt message
        choices: List of (value, label) tuples
        default: Default value
        use_shortcuts: Enable keyboard shortcuts (use value as shortcut key)

    Returns:
        Selected choice value

    Example:
        >>> choice = prompt_select(
        ...     "Select action:",
        ...     [("1", "Install packages"), ("2", "Remove packages"), ("0", "Exit")],
        ...     use_shortcuts=True
        ... )
    """
    # Custom style matching Rich theme with better visual feedback
    custom_style = Style([
        ('qmark', 'fg:cyan bold'),              # Question mark icon
        ('question', 'fg:cyan bold'),            # Question text
        ('answer', 'fg:green bold'),             # Final answer shown
        ('pointer', 'fg:yellow bold'),           # Pointer (►) - yellow for visibility
        ('highlighted', 'fg:white bold'),        # Current item - white/bold for clarity
        ('selected', 'fg:cyan'),                 # Selected state
        ('separator', 'fg:blue'),                # Separators
        ('instruction', 'fg:cyan'),              # Instructions at bottom
        ('text', 'fg:white'),                    # Default text
        ('disabled', 'fg:#666666 italic'),       # Disabled items - gray
    ])

    # Create choices for questionary
    questionary_choices = []
    for value, label in choices:
        if use_shortcuts:
            # Add shortcut hint to label
            questionary_choices.append(
                questionary.Choice(title=f"[{value}] {label}", value=value, shortcut_key=value)
            )
        else:
            questionary_choices.append(
                questionary.Choice(title=label, value=value)
            )

    result = questionary.select(
        message,
        choices=questionary_choices,
        default=default,
        style=custom_style,
        qmark="🚀",
        pointer="►",
        use_shortcuts=use_shortcuts,
    ).ask()

    return result if result is not None else (default or "")


def prompt_autocomplete(
    message: str,
    choices: List[str],
    fuzzy: bool = True,
    default: str = "",
) -> str:
    """
    Prompt with autocomplete support for package names

    Args:
        message: Prompt message
        choices: List of available choices for autocomplete
        fuzzy: Use fuzzy matching (default: True)
        default: Default value

    Returns:
        User input string with autocomplete

    Example:
        >>> packages = ["neovim", "neofetch", "neomutt", "vim", "gvim"]
        >>> choice = prompt_autocomplete("Enter package name:", packages)
        >>> # User types "neo" and sees: neovim, neofetch, neomutt
    """
    if fuzzy:
        completer = FuzzyCompleter(WordCompleter(choices, ignore_case=True))
    else:
        completer = WordCompleter(choices, ignore_case=True)

    result = prompt(
        f"{message}: ",
        completer=completer,
        default=default,
        complete_while_typing=True,
    )

    return result.strip() if result else default


def prompt_checkbox(
    message: str,
    choices: List[tuple[str, str]],
    default_selected: Optional[List[str]] = None,
) -> List[str]:
    """
    Interactive multi-select checkbox menu

    Args:
        message: Prompt message
        choices: List of (value, label) tuples
        default_selected: List of values to pre-select

    Returns:
        List of selected choice values

    Example:
        >>> selected = prompt_checkbox(
        ...     "Select packages to install:",
        ...     [
        ...         ("neovim", "Neovim - Hyperextensible text editor"),
        ...         ("tmux", "Terminal multiplexer"),
        ...         ("git", "Version control system"),
        ...     ]
        ... )
        >>> # Returns: ["neovim", "git"] if user selected those
    """
    # Custom style matching Rich theme with better visual feedback
    custom_style = Style([
        ('qmark', 'fg:cyan bold'),              # Question mark icon
        ('question', 'fg:cyan bold'),            # Question text
        ('answer', 'fg:green bold'),             # Final answer shown
        ('pointer', 'fg:yellow bold'),           # Pointer (►) - yellow for visibility
        ('highlighted', 'fg:white bold'),        # Current item - white/bold for clarity
        ('selected', 'fg:green bold'),           # Checked items - green checkmark
        ('separator', 'fg:blue'),                # Separators
        ('instruction', 'fg:cyan'),              # Instructions at bottom
        ('text', 'fg:white'),                    # Default text
        ('disabled', 'fg:#666666 italic'),       # Disabled items - gray
        ('checkbox', 'fg:green bold'),           # Checkbox when checked
        ('checkbox-selected', 'fg:green bold'),  # Selected checkbox
    ])

    # Create checkbox choices
    questionary_choices = []
    for value, label in choices:
        checked = False
        if default_selected and value in default_selected:
            checked = True
        questionary_choices.append(
            questionary.Choice(title=label, value=value, checked=checked)
        )

    result = questionary.checkbox(
        message,
        choices=questionary_choices,
        style=custom_style,
        qmark="📦",
        pointer="►",
        instruction="(Space to select, Enter to confirm)",
    ).ask()

    return result if result is not None else []


def prompt_autocomplete_multi(
    message: str,
    choices: List[str],
    separator: str = " ",
) -> List[str]:
    """
    Prompt for multiple items with autocomplete (space-separated)

    Args:
        message: Prompt message
        choices: List of available choices for autocomplete
        separator: Separator for multiple values (default: space)

    Returns:
        List of user-entered values

    Example:
        >>> packages = ["neovim", "tmux", "git"]
        >>> result = prompt_autocomplete_multi("Enter packages:", packages)
        >>> # User types "neovim tmux" with autocomplete
        >>> # Returns: ["neovim", "tmux"]
    """
    completer = FuzzyCompleter(WordCompleter(choices, ignore_case=True))

    result = prompt(
        f"{message} (space-separated): ",
        completer=completer,
        complete_while_typing=True,
    )

    if result:
        return [item.strip() for item in result.split(separator) if item.strip()]
    return []


# =============================================================================
# Tree Components
# =============================================================================


def create_dependency_tree(package: str, dependencies: dict[str, list[str]]) -> Tree:
    """
    Create a dependency tree

    Args:
        package: Root package name
        dependencies: Dictionary mapping packages to their dependencies

    Returns:
        Rich Tree object
    """
    tree = Tree(f"📦 [bold cyan]{package}[/bold cyan]")

    def add_deps(parent_tree: Tree, pkg: str, visited: set[str]) -> None:
        if pkg in visited:
            parent_tree.add(f"[dim]{pkg} (circular)[/dim]")
            return

        visited.add(pkg)
        deps = dependencies.get(pkg, [])

        for dep in deps:
            branch = parent_tree.add(f"[cyan]{dep}[/cyan]")
            add_deps(branch, dep, visited.copy())

    add_deps(tree, package, set())
    return tree


# =============================================================================
# Layout Components
# =============================================================================


def print_divider(char: str = "─", style: str = Colors.TEXT_DIM) -> None:
    """
    Print a horizontal divider

    Args:
        char: Character to use for divider
        style: Rich style
    """
    console.print(Rule(style=style))


def print_header(text: str, style: str = Colors.PRIMARY_BOLD) -> None:
    """
    Print a styled section header with rule

    Args:
        text: Header text
        style: Rich style
    """
    console.print()
    console.print(Rule(title=text, style=style))
    console.print()


def clear_screen() -> None:
    """Clear the terminal screen"""
    console.clear()


# =============================================================================
# Status Components
# =============================================================================


def display_operation_result(response: dict[str, Any]) -> None:
    """
    Display the result of a backend operation with a styled summary panel

    Args:
        response: Response dictionary from backend
    """
    status = response.get("status", "unknown")
    message = response.get("message", "Operation completed")
    data = response.get("data", {})

    if status == "success":
        display_success(message, data)
    elif status == "error":
        error = response.get("error", {})
        error_code = error.get("code")
        error_message = error.get("message", message)
        display_error(error_message, error_code)
    elif status == "warning":
        display_warning(message)
    else:
        display_info(message)

    # Display additional data in a structured way
    if data and isinstance(data, dict):
        details = Text()
        has_details = False

        if "installed" in data and data["installed"]:
            has_details = True
            details.append(f"\n  {Icons.SUCCESS} Installed: ", style=Colors.SUCCESS_BOLD)
            details.append(", ".join(data["installed"]), style=Colors.SUCCESS)
        if "removed" in data and data["removed"]:
            has_details = True
            details.append(f"\n  {Icons.SUCCESS} Removed: ", style=Colors.WARNING_BOLD)
            details.append(", ".join(data["removed"]), style=Colors.WARNING)
        if "failed" in data and data["failed"]:
            has_details = True
            details.append(f"\n  {Icons.ERROR} Failed: ", style=Colors.ERROR_BOLD)
            details.append(", ".join(data["failed"]), style=Colors.ERROR)

        if has_details:
            console.print(Panel(
                details,
                title="Operation Details",
                title_align="left",
                border_style=Colors.TEXT_DIM,
                padding=(0, 1),
            ))


# =============================================================================
# Utility Functions
# =============================================================================


def pause(message: str = "Press Enter to continue...") -> None:
    """
    Pause and wait for user to press Enter

    Args:
        message: Message to display
    """
    console.print(f"\n{message}", style="dim")
    input()


def display_installation_summary(
    packages: List[str],
    package_info: Optional[dict[str, dict[str, str]]] = None,
    operation: str = "install",
    fetch_info: bool = True,
    ask_recursive: bool = False
) -> tuple[bool, bool]:
    """
    Display summary before installing/removing packages

    Args:
        packages: List of package names
        package_info: Optional dict with package details (size, description, etc.)
        operation: Type of operation ("install" or "remove")
        fetch_info: Whether to fetch package info from backend (default: True)
        ask_recursive: Ask if user wants to remove dependencies (for remove operation)

    Returns:
        Tuple of (confirmed, remove_deps) - confirmed if user proceeds, remove_deps if should remove dependencies
    """
    if not packages:
        return (False, False)

    # Fetch package info from backend if not provided
    if package_info is None and fetch_info:
        from bridge.backend import BackendCaller
        backend = BackendCaller()
        package_info = {}

        # Fetch info for each package
        with console.status(f"[cyan]Fetching package information...", spinner="dots"):
            for pkg in packages:
                try:
                    response = backend.get_package_info(pkg, timeout=5)
                    if response.is_success() and response.data:
                        pkg_data = response.data
                        package_info[pkg] = {
                            "description": pkg_data.get("description", ""),
                            "size": pkg_data.get("installed_size", "Unknown"),
                            "version": pkg_data.get("version", ""),
                            "repository": pkg_data.get("repository", "")
                        }
                except Exception:
                    # Log the error for debugging, but continue with minimal info
                    logger.warning("Failed to fetch info for package '%s'", pkg, exc_info=True)
                    package_info[pkg] = {
                        "description": "Package information not available",
                        "size": "Unknown"
                    }

    # Create summary panel
    title = "📦 Installation Summary" if operation == "install" else "🗑️  Removal Summary"

    console.print()

    # Build summary content
    summary_lines = []
    summary_lines.append(f"[bold cyan]Packages to {operation}: {len(packages)}[/bold cyan]")

    total_size_kb = 0.0

    for pkg in packages:
        if package_info and pkg in package_info:
            info = package_info[pkg]
            size_str = info.get("size", "Unknown")

            # Parse size for display and total calculation
            try:
                # Handle various size formats from pacman
                size_clean = size_str.replace(",", "").strip()
                if "MiB" in size_clean or "MB" in size_clean:
                    size_val = float(size_clean.split()[0])
                    total_size_kb += size_val * 1024
                    size_display = f"{size_val:.1f} MB"
                elif "KiB" in size_clean or "KB" in size_clean:
                    size_val = float(size_clean.split()[0])
                    total_size_kb += size_val
                    size_display = f"{size_val:.0f} KB"
                elif "GiB" in size_clean or "GB" in size_clean:
                    size_val = float(size_clean.split()[0])
                    total_size_kb += size_val * 1024 * 1024
                    size_display = f"{size_val:.2f} GB"
                else:
                    size_display = size_str
            except (ValueError, IndexError):
                size_display = size_str

            summary_lines.append(f"  • [cyan]{pkg}[/cyan] ({size_display})")
        else:
            summary_lines.append(f"  • [cyan]{pkg}[/cyan]")

    # Add total size
    if total_size_kb > 0:
        summary_lines.append("")
        if total_size_kb >= 1024 * 1024:  # >= 1 GB
            total_display = f"{total_size_kb / (1024 * 1024):.2f} GB"
        elif total_size_kb >= 1024:  # >= 1 MB
            total_display = f"{total_size_kb / 1024:.1f} MB"
        else:
            total_display = f"{total_size_kb:.0f} KB"

        summary_lines.append(f"[bold yellow]Total installed size: ~{total_display}[/bold yellow]")

    # Display panel
    panel_content = "\n".join(summary_lines)
    console.print(Panel(
        panel_content,
        title=title,
        border_style="cyan",
        padding=(1, 2)
    ))
    console.print()

    # Ask about dependencies for remove operation
    remove_deps = False
    if ask_recursive and operation == "remove":
        console.print("[yellow]⚠️  Important:[/yellow] Removing these packages may leave dependencies orphaned.")
        console.print()
        console.print("Examples: [dim]vlc[/dim] has 30+ dependencies like [dim]vlc-cli, vlc-gui-qt, libvlc,[/dim] etc.")
        console.print()
        console.print("[bold]Options:[/bold]")
        console.print("  • [cyan]Remove with dependencies[/cyan] - Clean removal (recommended)")
        console.print("  • [cyan]Remove only packages[/cyan] - Keep dependencies (may leave orphans)")
        console.print()
        remove_deps = prompt_confirm("Remove dependencies too?", default=True)
        console.print()

    # Confirmation
    action = "installation" if operation == "install" else "removal"
    confirmed = prompt_confirm(f"Proceed with {action}?", default=True)

    return (confirmed, remove_deps)


def display_package_progress(
    packages: List[str],
    operation: str = "install",
    simulate: bool = False
) -> dict[str, Any]:
    """
    Display progress bar for multi-package operations

    Args:
        packages: List of package names
        operation: Type of operation ("install" or "remove")
        simulate: If True, simulates progress (for testing)

    Returns:
        Dictionary with results for each package
    """
    from rich.progress import (
        Progress,
        SpinnerColumn,
        BarColumn,
        TextColumn,
        TimeElapsedColumn,
        TimeRemainingColumn,
    )
    import time

    results = {}
    total = len(packages)

    # Create progress display
    progress = Progress(
        SpinnerColumn(),
        TextColumn("[bold blue]{task.description}"),
        BarColumn(),
        TextColumn("[progress.percentage]{task.percentage:>3.0f}%"),
        TextColumn("•"),
        TextColumn("{task.completed}/{task.total}"),
        TimeElapsedColumn(),
        console=console,
    )

    console.print()
    action = "Installing" if operation == "install" else "Removing"

    with progress:
        # Main progress task
        task = progress.add_task(
            f"[cyan]{action} packages...",
            total=total
        )

        # Process each package
        for idx, pkg in enumerate(packages, 1):
            # Update description to show current package
            progress.update(
                task,
                description=f"[cyan]{action} {pkg}...",
                completed=idx - 1
            )

            # Show status for completed packages
            if idx > 1:
                prev_pkg = packages[idx - 2]
                console.print(f"  ✅ [green]{prev_pkg}[/green] - {operation}ed")

            # Simulate or actual operation
            if simulate:
                time.sleep(1)  # Simulate work
                results[pkg] = {"status": "success"}
            else:
                # Actual backend call would go here
                # For now, we'll handle this at a higher level
                results[pkg] = {"status": "pending"}

            # Update progress
            progress.update(task, completed=idx)

        # Show last package completion
        if packages:
            console.print(f"  ✅ [green]{packages[-1]}[/green] - {operation}ed")

    console.print()
    return results


def install_packages_with_progress(
    packages: List[str],
    backend,
    as_deps: bool = False,
    debug: bool = False
) -> tuple[List[str], List[str]]:
    """
    Install packages one by one with progress tracking

    Args:
        packages: List of package names to install
        backend: BackendCaller instance
        as_deps: Install as dependencies
        debug: Enable debug output

    Returns:
        Tuple of (successful_packages, failed_packages)
    """
    from rich.progress import (
        Progress,
        SpinnerColumn,
        BarColumn,
        TextColumn,
        TimeElapsedColumn,
    )

    success = []
    failed = []
    total = len(packages)

    # Create progress display
    progress = Progress(
        SpinnerColumn(),
        TextColumn("[bold blue]{task.description}"),
        BarColumn(complete_style="green", finished_style="bold green"),
        TextColumn("[progress.percentage]{task.percentage:>3.0f}%"),
        TextColumn("•"),
        TextColumn("{task.completed}/{task.total}"),
        TimeElapsedColumn(),
        console=console,
    )

    console.print()

    with progress:
        # Main progress task
        task = progress.add_task(
            "[cyan]Installing packages...",
            total=total
        )

        # Process each package
        for idx, pkg in enumerate(packages, 1):
            # Update description to show current package
            progress.update(
                task,
                description=f"[cyan]Installing {pkg}...",
                completed=idx - 1
            )

            try:
                # Install single package
                if debug:
                    console.print(f"[dim]DEBUG: Installing {pkg}...[/dim]")
                response = backend.install_packages([pkg], no_confirm=True, as_deps=as_deps)

                if response.is_success():
                    # Double-check if package was actually installed
                    import subprocess
                    check = subprocess.run(
                        ["pacman", "-Q", pkg],
                        capture_output=True,
                        timeout=5
                    )

                    if check.returncode == 0:
                        # Package truly installed
                        success.append(pkg)
                        console.print(f"  ✅ [green]{pkg}[/green] - Installed")
                    else:
                        # Backend said success but package not installed
                        failed.append(pkg)
                        console.print(f"  ⚠️  [yellow]{pkg}[/yellow] - Installation reported success but package not found")
                else:
                    failed.append(pkg)
                    error_msg = response.message if hasattr(response, 'message') else "Unknown error"
                    console.print(f"  ❌ [red]{pkg}[/red] - Failed: {error_msg}")
            except Exception as e:
                failed.append(pkg)
                console.print(f"  ❌ [red]{pkg}[/red] - Error: {str(e)}")

            # Update progress
            progress.update(task, completed=idx)

    return success, failed


def remove_packages_with_progress(
    packages: List[str],
    backend,
    recursive: bool = False,
    debug: bool = False
) -> tuple[List[str], List[str]]:
    """
    Remove packages one by one with progress tracking

    Args:
        packages: List of package names to remove
        backend: BackendCaller instance
        recursive: Remove dependencies
        debug: Enable debug output

    Returns:
        Tuple of (successful_packages, failed_packages)
    """
    from rich.progress import (
        Progress,
        SpinnerColumn,
        BarColumn,
        TextColumn,
        TimeElapsedColumn,
    )

    success = []
    failed = []
    total = len(packages)

    # Create progress display
    progress = Progress(
        SpinnerColumn(),
        TextColumn("[bold blue]{task.description}"),
        BarColumn(complete_style="green", finished_style="bold green"),
        TextColumn("[progress.percentage]{task.percentage:>3.0f}%"),
        TextColumn("•"),
        TextColumn("{task.completed}/{task.total}"),
        TimeElapsedColumn(),
        console=console,
    )

    console.print()

    with progress:
        # Main progress task
        task = progress.add_task(
            "[cyan]Removing packages...",
            total=total
        )

        # Process each package
        for idx, pkg in enumerate(packages, 1):
            # Update description to show current package
            progress.update(
                task,
                description=f"[cyan]Removing {pkg}...",
                completed=idx - 1
            )

            try:
                # Remove single package
                if debug:
                    console.print(f"[dim]DEBUG: Removing {pkg}...[/dim]")
                response = backend.remove_packages([pkg], no_confirm=True, recursive=recursive)

                if response.is_success():
                    # Double-check if package was actually removed
                    import subprocess
                    check = subprocess.run(
                        ["pacman", "-Q", pkg],
                        capture_output=True,
                        timeout=5
                    )

                    if check.returncode != 0:
                        # Package truly removed
                        success.append(pkg)
                        console.print(f"  ✅ [green]{pkg}[/green] - Removed")
                    else:
                        # Backend said success but package still installed
                        failed.append(pkg)
                        console.print(f"  ⚠️  [yellow]{pkg}[/yellow] - Removal reported success but package still installed")
                else:
                    failed.append(pkg)
                    error_msg = response.message if hasattr(response, 'message') else "Unknown error"
                    console.print(f"  ❌ [red]{pkg}[/red] - Failed: {error_msg}")
            except Exception as e:
                failed.append(pkg)
                console.print(f"  ❌ [red]{pkg}[/red] - Error: {str(e)}")

            # Update progress
            progress.update(task, completed=idx)

    # After removal, suggest cleaning orphans
    if success and not recursive:
        console.print()
        console.print("[yellow]Tip:[/yellow] You may have orphaned packages left behind.")
        console.print("Run 'Remove orphans' from main menu to clean them up.")
        console.print()

    return success, failed


def print_json(data: dict[str, Any]) -> None:
    """
    Pretty print JSON data

    Args:
        data: Dictionary to print
    """
    console.print_json(data=data)
