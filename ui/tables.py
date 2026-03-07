"""
UI Tables - Table and panel builder components using Rich

Provides reusable Rich Table and Panel constructors for rendering
structured data such as package lists, search results, headers,
menus, and dependency trees.
"""

from __future__ import annotations

from rich.panel import Panel
from rich.table import Table
from rich.text import Text
from rich.tree import Tree

from ui.display import console
from ui.theme import APP_BANNER, APP_BANNER_SMALL, MENU_ITEMS, Colors, Icons, MenuCategory

# =============================================================================
# Generic Table
# =============================================================================


def create_table(
    title: str,
    columns: list[tuple[str, str]],
    rows: list[list[str]],
    show_header: bool = True,
    show_lines: bool = False,
) -> Table:
    """
    Create a generic Rich table.

    Args:
        title: Table title rendered above the table
        columns: List of ``(column_name, style)`` tuples
        rows: List of row data; each inner list must have the same
              length as ``columns``
        show_header: Whether to render the header row
        show_lines: Whether to draw lines between rows

    Returns:
        Configured Rich ``Table`` object (not yet printed)

    Example:
        >>> table = create_table(
        ...     "Packages",
        ...     [("Name", "cyan"), ("Version", "green")],
        ...     [["neovim", "0.9.5"], ["tmux", "3.3a"]],
        ... )
        >>> console.print(table)
    """
    table = Table(title=title, show_header=show_header, show_lines=show_lines)

    for col_name, col_style in columns:
        table.add_column(col_name, style=col_style)

    for row in rows:
        table.add_row(*row)

    return table


# =============================================================================
# Package-specific Tables
# =============================================================================


def create_package_table(packages: list[dict[str, str]]) -> Table:
    """
    Create a table for displaying a list of packages with status.

    Args:
        packages: List of package dicts. Recognised keys:
                  ``name``, ``version``, ``size``, ``status``.
                  Missing keys fall back to ``"N/A"`` / ``"installed"``.

    Returns:
        Configured Rich ``Table`` object
    """
    table = Table(
        title="📦 Packages",
        show_header=True,
        header_style=Colors.TABLE_HEADER,
    )

    table.add_column("#", style="dim", width=4)
    table.add_column("Name", style=Colors.PKG_NAME, no_wrap=True)
    table.add_column("Version", style=Colors.PKG_VERSION)
    table.add_column("Size", style=Colors.PKG_SIZE, justify="right")
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


def create_search_results_table(
    results: list[str],
    aur_results: list[str],
) -> Table:
    """
    Create a table for package search results split between official
    repositories and the AUR.

    Args:
        results: Package names from official repositories
        aur_results: Package names from the AUR

    Returns:
        Configured Rich ``Table`` object
    """
    table = Table(
        title="🔍 Search Results",
        show_header=True,
        header_style=Colors.TABLE_HEADER,
    )

    table.add_column("#", style="dim", width=4)
    table.add_column("Package", style=Colors.PKG_NAME)
    table.add_column("Repository", style=Colors.PKG_REPO)

    idx = 1
    for pkg in results:
        table.add_row(str(idx), pkg, "official")
        idx += 1

    for pkg in aur_results:
        table.add_row(str(idx), pkg, "[bold yellow]AUR[/bold yellow]")
        idx += 1

    return table


# =============================================================================
# Panel Builders
# =============================================================================


def create_panel(
    content: str,
    title: str = "",
    border_style: str = "blue",
    padding: tuple[int, int] = (1, 2),
) -> Panel:
    """
    Create a generic Rich panel.

    Args:
        content: Renderable content (string or Rich renderable)
        title: Optional title shown at the top of the border
        border_style: Rich style applied to the panel border
        padding: ``(vertical, horizontal)`` padding inside the panel

    Returns:
        Configured Rich ``Panel`` object
    """
    return Panel(
        content,
        title=title,
        border_style=border_style,
        padding=padding,
    )


def create_header(title: str, subtitle: str = "") -> Panel:
    """
    Create a compact page header panel with an optional subtitle.

    Args:
        title: Main heading text (rendered bold cyan)
        subtitle: Optional secondary line (rendered dim)

    Returns:
        Rich ``Panel`` suitable for printing at the top of a screen
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
    Build the main application ASCII-art banner with a colour gradient.

    Automatically switches to a smaller banner on narrow terminals
    (width < 60 columns).

    Returns:
        Rich ``Text`` object ready to be printed
    """
    width = console.width
    banner = APP_BANNER_SMALL if width < 60 else APP_BANNER

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

    text = Text()
    for i, line in enumerate(banner.split("\n")):
        color = gradient[i % len(gradient)]
        text.append(line + "\n", style=color)

    text.append(
        "    Hybrid Python/Zsh Package Manager for Arch Linux\n",
        style=Colors.TEXT_DIM,
    )
    return text


# =============================================================================
# Menu Panels
# =============================================================================


def create_menu_panel(items: list[tuple[str, str]]) -> Panel:
    """
    Create a simple key-based menu panel.

    Args:
        items: List of ``(key, description)`` tuples shown as
               ``[key] description`` lines

    Returns:
        Rich ``Panel`` containing the formatted menu
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
    Create the main grouped menu panel with category section headers.

    Groups menu items by category (Package Management, System
    Maintenance, Other) using ``MENU_ITEMS`` from ``ui.theme``.

    Returns:
        Rich ``Panel`` with the full categorised menu
    """
    section_icons = {
        MenuCategory.PACKAGE_MANAGEMENT: Icons.SECTION_PKG,
        MenuCategory.SYSTEM_MAINTENANCE: Icons.SECTION_SYS,
        MenuCategory.OTHER: Icons.SECTION_OTHER,
    }

    content = Text()

    for category, items in MENU_ITEMS.items():
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
# Dependency Tree
# =============================================================================


def create_dependency_tree(
    package: str,
    dependencies: dict[str, list[str]],
) -> Tree:
    """
    Build a Rich ``Tree`` showing the dependency graph for a package.

    Circular dependencies are detected and labelled ``(circular)``
    instead of being expanded further.

    Args:
        package: Name of the root package
        dependencies: Mapping from package name to its direct
                      dependency names

    Returns:
        Rich ``Tree`` object ready to be printed

    Example:
        >>> tree = create_dependency_tree(
        ...     "vlc",
        ...     {"vlc": ["ffmpeg", "qt5-base"], "ffmpeg": ["libx264"]},
        ... )
        >>> console.print(tree)
    """
    tree = Tree(f"📦 [bold cyan]{package}[/bold cyan]")

    def _add_deps(parent: Tree, pkg: str, visited: set[str]) -> None:
        if pkg in visited:
            parent.add(f"[dim]{pkg} (circular)[/dim]")
            return

        visited.add(pkg)
        for dep in dependencies.get(pkg, []):
            branch = parent.add(f"[cyan]{dep}[/cyan]")
            _add_deps(branch, dep, visited.copy())

    _add_deps(tree, package, set())
    return tree


# =============================================================================
# Misc
# =============================================================================


def print_json(data: dict) -> None:
    """
    Pretty-print a dictionary as JSON to the console.

    Args:
        data: Dictionary to serialise and display
    """
    import json

    console.print_json(json.dumps(data))
