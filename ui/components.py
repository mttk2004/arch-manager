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

from typing import Any, Callable, List, Optional

import questionary
from prompt_toolkit.completion import FuzzyCompleter, WordCompleter
from prompt_toolkit.shortcuts import prompt
from questionary import Style
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
from rich.table import Table
from rich.text import Text
from rich.tree import Tree

# Global console instance
console = Console()


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
    text = Text()
    text.append("✅ SUCCESS: ", style="bold green")
    text.append(message, style="green")
    console.print(text)

    if data:
        console.print(data, style="dim")


def display_error(message: str, error_code: Optional[str] = None) -> None:
    """
    Display error message

    Args:
        message: Error message
        error_code: Optional error code
    """
    text = Text()
    text.append("❌ ERROR: ", style="bold red")
    text.append(message, style="red")

    if error_code:
        text.append(f" (Code: {error_code})", style="dim red")

    console.print(text)


def display_warning(message: str) -> None:
    """
    Display warning message

    Args:
        message: Warning message
    """
    text = Text()
    text.append("⚠️  WARNING: ", style="bold yellow")
    text.append(message, style="yellow")
    console.print(text)


def display_info(message: str) -> None:
    """
    Display info message

    Args:
        message: Info message
    """
    text = Text()
    text.append("ℹ️  INFO: ", style="bold cyan")
    text.append(message, style="cyan")
    console.print(text)


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
    Create application header

    Args:
        title: Main title
        subtitle: Optional subtitle

    Returns:
        Rich Panel object
    """
    content = Text()
    content.append(title, style="bold cyan")
    if subtitle:
        content.append("\n")
        content.append(subtitle, style="dim")

    return Panel(
        content,
        border_style="bright_blue",
        padding=(1, 2),
    )


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
        content.append(f"  [{key}] ", style="bold cyan")
        content.append(f"{description}\n", style="white")

    return Panel(
        content,
        title="📋 Menu",
        border_style="cyan",
        padding=(1, 2),
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
) -> str:
    """
    Interactive selection menu with arrow key navigation

    Args:
        message: Prompt message
        choices: List of (value, label) tuples
        default: Default value

    Returns:
        Selected choice value

    Example:
        >>> choice = prompt_select(
        ...     "Select action:",
        ...     [("1", "Install packages"), ("2", "Remove packages"), ("0", "Exit")]
        ... )
    """
    # Custom style matching Rich theme
    custom_style = Style([
        ('qmark', 'fg:cyan bold'),           # Question mark
        ('question', 'fg:cyan bold'),         # Question text
        ('answer', 'fg:green bold'),          # Selected answer
        ('pointer', 'fg:cyan bold'),          # Pointer (>)
        ('highlighted', 'fg:cyan bold'),      # Highlighted option
        ('selected', 'fg:green'),             # Selected option
        ('separator', 'fg:blue'),             # Separator
        ('instruction', 'fg:yellow'),         # Instructions
        ('text', 'fg:white'),                 # Default text
        ('disabled', 'fg:#858585 italic'),    # Disabled options
    ])

    # Create choices for questionary
    questionary_choices = [
        questionary.Choice(title=label, value=value)
        for value, label in choices
    ]

    result = questionary.select(
        message,
        choices=questionary_choices,
        default=default,
        style=custom_style,
        qmark="🚀",
        pointer="►",
        use_shortcuts=True,
        use_arrow_keys=True,
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
    # Custom style matching Rich theme
    custom_style = Style([
        ('qmark', 'fg:cyan bold'),
        ('question', 'fg:cyan bold'),
        ('answer', 'fg:green bold'),
        ('pointer', 'fg:cyan bold'),
        ('highlighted', 'fg:cyan bold'),
        ('selected', 'fg:green'),
        ('separator', 'fg:blue'),
        ('instruction', 'fg:yellow'),
        ('text', 'fg:white'),
        ('disabled', 'fg:#858585 italic'),
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
        use_shortcuts=True,
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


def print_divider(char: str = "─", style: str = "dim") -> None:
    """
    Print a horizontal divider

    Args:
        char: Character to use for divider
        style: Rich style
    """
    console.print(char * console.width, style=style)


def print_header(text: str, style: str = "bold cyan") -> None:
    """
    Print a styled header

    Args:
        text: Header text
        style: Rich style
    """
    console.print(f"\n{text}", style=style)
    print_divider()


def clear_screen() -> None:
    """Clear the terminal screen"""
    console.clear()


# =============================================================================
# Status Components
# =============================================================================


def display_operation_result(response: dict[str, Any]) -> None:
    """
    Display the result of a backend operation

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

    # Display additional data if present
    if data and isinstance(data, dict):
        if "installed" in data and data["installed"]:
            console.print(f"\nInstalled: {', '.join(data['installed'])}", style="green")
        if "removed" in data and data["removed"]:
            console.print(f"\nRemoved: {', '.join(data['removed'])}", style="yellow")
        if "failed" in data and data["failed"]:
            console.print(f"\nFailed: {', '.join(data['failed'])}", style="red")


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


def print_json(data: dict[str, Any]) -> None:
    """
    Pretty print JSON data

    Args:
        data: Dictionary to print
    """
    console.print_json(data=data)
