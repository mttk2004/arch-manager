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
    prompt_choice,
    prompt_confirm,
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
        # Show what will be installed
        display_info(f"Preparing to install: {', '.join(packages)}")

        # Confirm installation
        if not no_confirm:
            if not prompt_confirm(f"Install {len(packages)} package(s)?", default=True):
                display_warning("Installation cancelled")
                return

        # Create progress bar
        progress, task = show_progress("Installing packages...", total=len(packages))
        progress.start()

        # Call backend
        response = backend.install_packages(packages, no_confirm=True, as_deps=as_deps)

        progress.stop()

        # Display results
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
        # Show what will be removed
        display_warning(f"Preparing to remove: {', '.join(packages)}")

        # Confirm removal
        if not no_confirm:
            if not prompt_confirm(f"Remove {len(packages)} package(s)?", default=False):
                display_info("Removal cancelled")
                return

        # Call backend
        response = backend.remove_packages(packages, no_confirm=True, recursive=recursive)

        # Display results
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

        # Display menu
        menu_items = [
            ("1", "Install packages"),
            ("2", "Remove packages"),
            ("3", "Search packages"),
            ("4", "Update system"),
            ("5", "List installed packages"),
            ("6", "Package information"),
            ("7", "Clean cache"),
            ("8", "Remove orphans"),
            ("9", "Font manager"),
            ("0", "Exit"),
        ]

        menu_panel = create_menu_panel(menu_items)
        console.print(menu_panel)

        # Get user choice
        choice = prompt_text("\nEnter your choice", default="0")

        try:
            if choice == "1":
                packages_input = prompt_text("Enter package names (space-separated)")
                packages = packages_input.split()
                if packages:
                    install(packages, no_confirm=False, as_deps=False)
                    pause()

            elif choice == "2":
                packages_input = prompt_text("Enter package names (space-separated)")
                packages = packages_input.split()
                if packages:
                    remove(packages, no_confirm=False, recursive=False)
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
