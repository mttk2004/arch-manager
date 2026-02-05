#!/usr/bin/env python3
"""
Demo script to showcase the new interactive menu with arrow-key navigation
"""

from __future__ import annotations

import sys
from pathlib import Path

# Add project root to Python path
PROJECT_ROOT = Path(__file__).parent
sys.path.insert(0, str(PROJECT_ROOT))

from ui.components import (
    clear_screen,
    console,
    create_header,
    display_info,
    display_success,
    prompt_select,
)


def main() -> None:
    """Run interactive menu demo"""
    clear_screen()

    # Display header
    header = create_header(
        "🚀 Interactive Menu Demo",
        "Use ↑↓ arrow keys to navigate, Enter to select",
    )
    console.print(header)
    console.print()

    # Menu items with icons
    menu_items = [
        ("install", "📦 Install packages"),
        ("remove", "🗑️  Remove packages"),
        ("search", "🔍 Search packages"),
        ("update", "⬆️  Update system"),
        ("list", "📋 List installed packages"),
        ("info", "ℹ️  Package information"),
        ("clean", "🧹 Clean cache"),
        ("orphans", "♻️  Remove orphans"),
        ("fonts", "🔤 Font manager"),
        ("exit", "❌ Exit"),
    ]

    while True:
        console.print("[bold cyan]Main Menu:[/bold cyan]\n")

        # Get user choice using interactive arrow-key menu
        choice = prompt_select(
            "What would you like to do?",
            menu_items,
            default="exit"
        )

        console.print()

        if choice == "install":
            display_info("Selected: Install packages")
            console.print("[dim]This would call install_packages() function[/dim]\n")

        elif choice == "remove":
            display_info("Selected: Remove packages")
            console.print("[dim]This would call remove_packages() function[/dim]\n")

        elif choice == "search":
            display_info("Selected: Search packages")
            console.print("[dim]This would call search_packages() function[/dim]\n")

        elif choice == "update":
            display_info("Selected: Update system")
            console.print("[dim]This would call update_system() function[/dim]\n")

        elif choice == "list":
            display_info("Selected: List installed packages")
            console.print("[dim]This would call list_packages() function[/dim]\n")

        elif choice == "info":
            display_info("Selected: Package information")
            console.print("[dim]This would call package_info() function[/dim]\n")

        elif choice == "clean":
            display_info("Selected: Clean cache")
            console.print("[dim]This would call clean_cache() function[/dim]\n")

        elif choice == "orphans":
            display_info("Selected: Remove orphans")
            console.print("[dim]This would call remove_orphans() function[/dim]\n")

        elif choice == "fonts":
            display_info("Selected: Font manager")
            console.print("[dim]This would call font_manager() function[/dim]\n")

        elif choice == "exit":
            display_success("Goodbye! 👋")
            break

        else:
            console.print(f"[red]Unknown choice: {choice}[/red]\n")

        # Wait before showing menu again
        console.print("[dim]Press Enter to continue...[/dim]")
        input()
        console.print("\n" + "─" * 80 + "\n")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        console.print("\n")
        display_success("Interrupted. Goodbye! 👋")
        sys.exit(0)
