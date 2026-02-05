#!/usr/bin/env python3
"""
Arch Zsh Manager - Hybrid Python/Zsh Package Manager
Main CLI Application Entry Point

A beautiful terminal package manager for Arch Linux that combines:
- Python Rich library for stunning UI/UX
- Zsh backend scripts for native system operations
"""

from __future__ import annotations

import sys
from pathlib import Path
from typing import List, Optional

import typer
from rich.console import Console
from rich.panel import Panel
from rich.text import Text

# Add project root to Python path
PROJECT_ROOT = Path(__file__).parent
sys.path.insert(0, str(PROJECT_ROOT))

from bridge.backend import BackendCaller
from bridge.errors import BackendError, BackendTimeoutError, InvalidResponseError
from ui.components import (
    clear_screen,
    console,
    create_header,
    create_menu_panel,
    create_package_table,
    create_search_results_table,
    display_error,
    display_info,
    display_operation_result,
    display_success,
    display_warning,
    pause,
    print_divider,
    print_header,
    prompt_autocomplete,
    prompt_autocomplete_multi,
    prompt_checkbox,
    prompt_choice,
    prompt_confirm,
    prompt_select,
    prompt_text,
    show_progress,
)



# Initialize Typer app
app = typer.Typer(
    name="pkgman",
    help="Arch Zsh Manager - Beautiful package manager for Arch Linux",
    add_completion=True,
)

# Initialize backend caller
backend = BackendCaller()

# Cache for package lists (to avoid repeated backend calls)
_package_cache = {
    "available": None,
    "installed": None,
}


# =============================================================================
# Helper Functions
# =============================================================================


def get_available_packages(force_refresh: bool = False) -> List[str]:
    """
    Get list of available packages for autocomplete (with caching)

    Args:
        force_refresh: Force refresh cache

    Returns:
        List of available package names
    """
    global _package_cache

    if _package_cache["available"] is None or force_refresh:
        try:
            response = backend.list_available_packages(timeout=30)
            if response.is_success() and response.data:
                _package_cache["available"] = response.data.get("packages", [])
            else:
                _package_cache["available"] = []
        except Exception as e:
            display_warning(f"Could not load package list: {e}")
            _package_cache["available"] = []

    return _package_cache["available"]


def get_installed_packages(force_refresh: bool = False) -> List[str]:
    """
    Get list of installed packages for autocomplete (with caching)

    Args:
        force_refresh: Force refresh cache

    Returns:
        List of installed package names
    """
    global _package_cache

    if _package_cache["installed"] is None or force_refresh:
        try:
            response = backend.list_installed_names(timeout=10)
            if response.is_success() and response.data:
                _package_cache["installed"] = response.data.get("packages", [])
            else:
                _package_cache["installed"] = []
        except Exception as e:
            display_warning(f"Could not load installed packages: {e}")
            _package_cache["installed"] = []

    return _package_cache["installed"]


# =============================================================================
# CLI Commands
# =============================================================================


@app.command()
def install(
    packages: List[str] = typer.Argument(..., help="Package names to install"),
    no_confirm: bool = typer.Option(False, "--no-confirm", "-y", help="Skip confirmations"),
    as_deps: bool = typer.Option(False, "--as-deps", "-d", help="Install as dependencies"),
) -> None:
    """
    Install packages

    Example:
        pkgman install neovim tmux git
    """
    console.print(create_header("📦 Package Installation", "Installing packages..."))

    try:
        # Show installation summary and get confirmation
        if not no_confirm:
            from ui.components import display_installation_summary

            if not display_installation_summary(packages, operation="install"):
                display_warning("Installation cancelled")
                return
        else:
            display_info(f"Preparing to install: {', '.join(packages)}")

        # Install packages with progress tracking
        if len(packages) > 1:
            # Multi-package installation with progress bar
            from ui.components import install_packages_with_progress
            success, failed = install_packages_with_progress(packages, backend, as_deps=as_deps)

            console.print()
            if success:
                display_success(f"Successfully installed {len(success)} package(s)")
            if failed:
                display_error(f"Failed to install {len(failed)} package(s): {', '.join(failed)}")
        else:
            # Single package - use simple spinner
            with console.status("[cyan]Installing packages...", spinner="dots"):
                response = backend.install_packages(packages, no_confirm=True, as_deps=as_deps)
            display_operation_result(response.to_dict())

    except BackendError as e:
        display_error(str(e), e.code)
        raise typer.Exit(code=1)


@app.command()
def remove(
    packages: List[str] = typer.Argument(..., help="Package names to remove"),
    no_confirm: bool = typer.Option(False, "--no-confirm", "-y", help="Skip confirmations"),
    recursive: bool = typer.Option(False, "--recursive", "-r", help="Remove dependencies"),
) -> None:
    """
    Remove packages

    Example:
        pkgman remove neovim
    """
    console.print(create_header("🗑️  Package Removal", "Removing packages..."))

    try:
        # Show removal summary and get confirmation
        if not no_confirm:
            from ui.components import display_installation_summary

            if not display_installation_summary(packages, operation="remove"):
                display_warning("Removal cancelled")
                return
        else:
            display_info(f"Preparing to remove: {', '.join(packages)}")

        # Remove packages with progress tracking
        if len(packages) > 1:
            # Multi-package removal with progress bar
            from ui.components import remove_packages_with_progress
            success, failed = remove_packages_with_progress(packages, backend, recursive=recursive)

            console.print()
            if success:
                display_success(f"Successfully removed {len(success)} package(s)")
            if failed:
                display_error(f"Failed to remove {len(failed)} package(s): {', '.join(failed)}")
        else:
            # Single package - use simple spinner
            with console.status("[cyan]Removing packages...", spinner="dots"):
                response = backend.remove_packages(packages, no_confirm=True, recursive=recursive)
            display_operation_result(response.to_dict())

    except BackendError as e:
        display_error(str(e), e.code)
        raise typer.Exit(code=1)


@app.command()
def search(
    query: str = typer.Argument(..., help="Search query"),
    aur: bool = typer.Option(False, "--aur", "-a", help="Include AUR packages"),
) -> None:
    """
    Search for packages

    Example:
        pkgman search vim
        pkgman search --aur neovim
    """
    console.print(create_header("🔍 Package Search", f"Searching for: {query}"))

    try:
        # Call backend
        response = backend.search_packages(query, aur=aur)

        if response.is_success() and response.data:
            official = response.data.get("official", [])
            aur_results = response.data.get("aur", [])
            total = response.data.get("total_count", 0)

            if total == 0:
                display_warning(f"No packages found matching '{query}'")
            else:
                # Create and display results table
                table = create_search_results_table(official, aur_results)
                console.print(table)

                display_success(f"Found {total} matching package(s)")
        else:
            display_warning("No results found")

    except BackendError as e:
        display_error(str(e), e.code)
        raise typer.Exit(code=1)


@app.command()
def info(
    package: str = typer.Argument(..., help="Package name"),
) -> None:
    """
    Show package information

    Example:
        pkgman info neovim
    """
    console.print(create_header("ℹ️  Package Information", f"Package: {package}"))

    try:
        # Call backend
        response = backend.get_package_info(package)

        if response.is_success() and response.data:
            data = response.data

            # Create info panel
            info_text = Text()
            info_text.append("Name: ", style="bold cyan")
            info_text.append(f"{data.get('name', 'N/A')}\n")

            info_text.append("Version: ", style="bold green")
            info_text.append(f"{data.get('version', 'N/A')}\n")

            info_text.append("Repository: ", style="bold yellow")
            info_text.append(f"{data.get('repository', 'N/A')}\n")

            info_text.append("Installed: ", style="bold magenta")
            installed = "Yes ✅" if data.get("installed") == "true" else "No ❌"
            info_text.append(f"{installed}\n")

            info_text.append("Size: ", style="bold blue")
            info_text.append(f"{data.get('installed_size', 'N/A')}\n")

            info_text.append("\nDescription: ", style="bold white")
            info_text.append(f"{data.get('description', 'N/A')}\n")

            info_text.append("URL: ", style="bold cyan")
            info_text.append(f"{data.get('url', 'N/A')}")

            panel = Panel(info_text, title=f"📦 {package}", border_style="cyan")
            console.print(panel)

    except BackendError as e:
        display_error(str(e), e.code)
        raise typer.Exit(code=1)


@app.command()
def list(
    explicit: bool = typer.Option(False, "--explicit", "-e", help="Only explicitly installed"),
) -> None:
    """
    List installed packages

    Example:
        pkgman list
        pkgman list --explicit
    """
    title = "Explicitly Installed Packages" if explicit else "All Installed Packages"
    console.print(create_header("📋 Package List", title))

    try:
        # Call backend
        response = backend.list_installed(explicit_only=explicit)

        if response.is_success() and response.data:
            packages = response.data.get("packages", [])
            count = response.data.get("count", 0)

            if count == 0:
                display_warning("No packages found")
            else:
                # Display packages in columns
                console.print(f"\n[cyan]Total: {count} packages[/cyan]\n")

                # Display first 20, then ask to continue
                display_limit = 20
                for i, pkg in enumerate(packages[:display_limit], start=1):
                    console.print(f"{i:4d}. {pkg}")

                if count > display_limit:
                    console.print(f"\n[dim]... and {count - display_limit} more[/dim]")

                    if prompt_confirm("Show all packages?", default=False):
                        for i, pkg in enumerate(packages[display_limit:], start=display_limit + 1):
                            console.print(f"{i:4d}. {pkg}")

    except BackendError as e:
        display_error(str(e), e.code)
        raise typer.Exit(code=1)


@app.command()
def update(
    no_confirm: bool = typer.Option(False, "--no-confirm", "-y", help="Skip confirmations"),
    aur: bool = typer.Option(False, "--aur", "-a", help="Include AUR packages"),
) -> None:
    """
    Update system packages

    Example:
        pkgman update
        pkgman update --aur
    """
    console.print(create_header("⬆️  System Update", "Updating system packages..."))

    try:
        # Check for updates first
        display_info("Checking for updates...")
        check_response = backend.call("package", "check_updates")

        if check_response.is_success() and check_response.data:
            updates_count = check_response.data.get("count", 0)

            if updates_count == 0:
                display_success("System is already up to date! 🎉")
                return

            display_info(f"Found {updates_count} available update(s)")

            # Confirm update
            if not no_confirm:
                if not prompt_confirm("Proceed with system update?", default=True):
                    display_info("Update cancelled")
                    return

            # Perform update
            progress, task = show_progress("Updating system...", total=None)
            progress.start()

            response = backend.update_system(no_confirm=True, aur=aur)

            progress.stop()

            # Display results
            display_operation_result(response.to_dict())

    except BackendError as e:
        display_error(str(e), e.code)
        raise typer.Exit(code=1)


@app.command()
def clean(
    keep: int = typer.Option(3, "--keep", "-k", help="Number of versions to keep"),
) -> None:
    """
    Clean package cache

    Example:
        pkgman clean
        pkgman clean --keep 2
    """
    console.print(create_header("🧹 Cache Cleanup", "Cleaning package cache..."))

    try:
        if prompt_confirm(f"Clean cache (keeping {keep} versions)?", default=True):
            response = backend.clean_cache(keep_versions=keep)
            display_operation_result(response.to_dict())
        else:
            display_info("Cleanup cancelled")

    except BackendError as e:
        display_error(str(e), e.code)
        raise typer.Exit(code=1)


@app.command()
def menu() -> None:
    """
    Show interactive menu (default)
    """
    run_interactive_menu()


def run_interactive_menu() -> None:
    """Run the interactive main menu"""
    while True:
        clear_screen()

        # Display header
        header = create_header(
            "🚀 Arch Zsh Manager",
            "Hybrid Python/Zsh Package Manager for Arch Linux",
        )
        console.print(header)
        console.print()

        # Define menu options with icons
        menu_items = [
            ("1", "📦 Install packages"),
            ("2", "🗑️  Remove packages"),
            ("3", "🔍 Search packages"),
            ("4", "⬆️  Update system"),
            ("5", "📋 List installed packages"),
            ("6", "ℹ️  Package information"),
            ("7", "🧹 Clean cache"),
            ("8", "♻️  Remove orphans"),
            ("9", "🔤 Font manager"),
            ("0", "❌ Exit"),
        ]

        # Get user choice using interactive arrow-key menu
        console.print("[bold cyan]Use arrow keys (↑↓) to navigate, Enter to select, or press number (0-9):[/bold cyan]\n")
        choice = prompt_select(
            "Select an action:",
            menu_items,
            use_shortcuts=True
        )

        try:
            if choice == "1":
                # Install packages with multi-select
                # Load package lists with spinner
                with console.status("[cyan]Loading package lists...", spinner="dots"):
                    available = get_available_packages()
                    installed = get_installed_packages()

                if not available:
                    display_warning("Could not load package list. Use manual input.")
                    packages_input = prompt_text("Enter package names (space-separated)")
                    packages = packages_input.split()
                else:
                    # Show popular/suggested packages for quick selection
                    popular_choices = []
                    suggested = [
                        ("neovim", "Hyperextensible Vim-based text editor"),
                        ("git", "Distributed version control system"),
                        ("tmux", "Terminal multiplexer"),
                        ("docker", "Container platform"),
                        ("vim", "Vi IMproved text editor"),
                        ("htop", "Interactive process viewer"),
                        ("btop", "Resource monitor (modern)"),
                        ("firefox", "Mozilla web browser"),
                        ("chromium", "Google Chromium browser"),
                        ("vlc", "VLC media player"),
                        ("wget", "Network downloader"),
                        ("curl", "URL transfer tool"),
                        ("zsh", "Z Shell"),
                        ("bash-completion", "Bash completion support"),
                        ("ripgrep", "Fast search tool (rg)"),
                        ("fzf", "Fuzzy finder"),
                        ("fd", "Fast find alternative"),
                        ("bat", "Cat clone with syntax highlighting"),
                        ("exa", "Modern ls replacement"),
                        ("lazygit", "Terminal UI for git"),
                    ]

                    for pkg_name, pkg_desc in suggested:
                        if pkg_name in available:
                            # Check if already installed
                            if pkg_name in installed:
                                popular_choices.append((pkg_name, f"✅ {pkg_name} - {pkg_desc} (installed)"))
                            else:
                                popular_choices.append((pkg_name, f"📦 {pkg_name} - {pkg_desc}"))

                    console.print("\n[bold]Option 1:[/bold] Select from popular packages (✅ = already installed)")
                    console.print("[bold]Option 2:[/bold] Search and type package names with autocomplete\n")

                    method = prompt_select(
                        "Choose input method:",
                        [("multi", "Multi-select from popular packages"), ("auto", "Autocomplete search")]
                    )

                    if method == "multi" and popular_choices:
                        packages = prompt_checkbox(
                            "Select packages to install (skip already installed):",
                            popular_choices
                        )

                        # Filter out already installed packages
                        if packages:
                            not_installed = [pkg for pkg in packages if pkg not in installed]
                            already_installed = [pkg for pkg in packages if pkg in installed]

                            if already_installed:
                                display_info(f"Skipping already installed: {', '.join(already_installed)}")

                            packages = not_installed

                            if not packages:
                                display_warning("All selected packages are already installed.")
                    else:
                        # Autocomplete input
                        packages = prompt_autocomplete_multi(
                            "Enter package names",
                            available
                        )

                if packages:
                    install(packages, no_confirm=False, as_deps=False)
                    # Clear cache after install
                    _package_cache["installed"] = None
                    pause()

            elif choice == "2":
                # Remove packages with autocomplete from installed
                # Load installed packages with spinner
                with console.status("[cyan]Loading installed packages...", spinner="dots"):
                    installed = get_installed_packages()

                if not installed:
                    display_warning("Could not load installed packages. Use manual input.")
                    packages_input = prompt_text("Enter package names (space-separated)")
                    packages = packages_input.split()
                else:
                    console.print("\n[bold]Option 1:[/bold] Multi-select packages to remove")
                    console.print("[bold]Option 2:[/bold] Type package names with autocomplete\n")

                    method = prompt_select(
                        "Choose input method:",
                        [("multi", "Multi-select packages"), ("auto", "Autocomplete search")]
                    )

                    if method == "multi":
                        # Show installed packages for multi-select (limit to first 50)
                        choices = [(pkg, pkg) for pkg in installed[:50]]
                        if len(installed) > 50:
                            console.print(f"\n[dim]Showing first 50 of {len(installed)} packages[/dim]")

                        packages = prompt_checkbox(
                            "Select packages to remove:",
                            choices
                        )
                    else:
                        packages = prompt_autocomplete_multi(
                            "Enter package names",
                            installed
                        )

                if packages:
                    remove(packages, no_confirm=False, recursive=False)
                    # Clear cache after remove
                    _package_cache["installed"] = None
                    pause()

            elif choice == "3":
                query = prompt_text("Enter search query")
                if query:
                    search(query, aur=True)
                    pause()

            elif choice == "4":
                update(no_confirm=False, aur=True)
                pause()

            elif choice == "5":
                explicit = prompt_confirm("Show only explicit packages?", default=False)
                list(explicit=explicit)
                pause()

            elif choice == "6":
                package = prompt_text("Enter package name")
                if package:
                    info(package)
                    pause()

            elif choice == "7":
                clean(keep=3)
                pause()

            elif choice == "8":
                display_info("Removing orphaned packages...")
                response = backend.remove_orphans(no_confirm=False)
                display_operation_result(response.to_dict())
                pause()

            elif choice == "9":
                display_info("Font manager - Coming soon!")
                pause()

            elif choice == "0":
                display_success("Goodbye! 👋")
                break

            else:
                display_warning("Invalid choice. Please try again.")
                pause()

        except KeyboardInterrupt:
            console.print("\n")
            if prompt_confirm("Exit program?", default=False):
                break
        except Exception as e:
            display_error(f"An error occurred: {e}")
            pause()


@app.callback(invoke_without_command=True)
def main(
    ctx: typer.Context,
    version: bool = typer.Option(False, "--version", "-v", help="Show version"),
) -> None:
    """
    Arch Zsh Manager - Hybrid Python/Zsh Package Manager

    Run without arguments to start interactive menu.
    """
    if version:
        console.print("[bold cyan]Arch Zsh Manager[/bold cyan] version [green]2.0.0[/green]")
        console.print("[dim]Hybrid Python/Zsh Architecture[/dim]")
        raise typer.Exit()

    # If no subcommand provided, run interactive menu
    if ctx.invoked_subcommand is None:
        run_interactive_menu()


if __name__ == "__main__":
    app()
