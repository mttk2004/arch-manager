#!/usr/bin/env python3
"""
Demo script for Autocomplete and Multi-Select features

This script demonstrates:
1. Autocomplete with fuzzy matching
2. Multi-select checkbox menus
3. Autocomplete for multiple items
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
    display_warning,
    prompt_autocomplete,
    prompt_autocomplete_multi,
    prompt_checkbox,
    prompt_select,
)


def demo_autocomplete():
    """Demo: Single package autocomplete"""
    clear_screen()
    console.print(create_header(
        "🔍 Autocomplete Demo",
        "Type to search packages with fuzzy matching"
    ))
    console.print()

    # Simulated package list
    packages = [
        "neovim", "neofetch", "neomutt",
        "vim", "gvim", "nvim-qt",
        "tmux", "screen", "byobu",
        "git", "github-cli", "gitlab-runner",
        "docker", "docker-compose", "podman",
        "python", "python-pip", "python-poetry",
        "nodejs", "npm", "yarn",
        "firefox", "chromium", "brave-bin",
        "vscode", "sublime-text", "emacs",
    ]

    console.print("[bold cyan]Available packages:[/bold cyan]")
    console.print(", ".join(packages[:10]) + ", ...")
    console.print()

    display_info("Try typing: 'neo', 'git', 'py', etc.")
    display_info("Use Tab for suggestions, Up/Down arrows to navigate")
    console.print()

    package = prompt_autocomplete(
        "Enter package name",
        packages,
        fuzzy=True,
    )

    console.print()
    if package:
        display_success(f"Selected: {package}")
    else:
        display_warning("No package selected")

    console.print("\n[dim]Press Enter to continue...[/dim]")
    input()


def demo_autocomplete_multi():
    """Demo: Multiple packages with autocomplete"""
    clear_screen()
    console.print(create_header(
        "🔍 Multi-Package Autocomplete Demo",
        "Type multiple packages separated by space"
    ))
    console.print()

    packages = [
        "neovim", "vim", "emacs",
        "tmux", "screen",
        "git", "github-cli",
        "docker", "docker-compose",
        "python", "python-pip",
        "nodejs", "npm",
        "firefox", "chromium",
    ]

    console.print("[bold cyan]Available packages:[/bold cyan]")
    console.print(", ".join(packages))
    console.print()

    display_info("Type multiple package names separated by spaces")
    display_info("Autocomplete works for each package name")
    console.print()

    selected = prompt_autocomplete_multi(
        "Enter package names",
        packages,
    )

    console.print()
    if selected:
        display_success(f"Selected {len(selected)} package(s):")
        for pkg in selected:
            console.print(f"  • {pkg}")
    else:
        display_warning("No packages selected")

    console.print("\n[dim]Press Enter to continue...[/dim]")
    input()


def demo_checkbox():
    """Demo: Multi-select checkbox menu"""
    clear_screen()
    console.print(create_header(
        "☑️  Multi-Select Checkbox Demo",
        "Use Space to toggle, Enter to confirm"
    ))
    console.print()

    # Simulate some packages already installed
    installed = ["git", "python", "htop"]

    choices = []
    packages = [
        ("neovim", "Neovim - Hyperextensible Vim-based text editor"),
        ("tmux", "Terminal multiplexer"),
        ("git", "Distributed version control system"),
        ("docker", "Container platform"),
        ("python", "Programming language"),
        ("nodejs", "JavaScript runtime"),
        ("firefox", "Web browser"),
        ("vlc", "VLC media player"),
        ("htop", "Interactive process viewer"),
        ("btop", "Resource monitor"),
    ]

    # Mark installed packages
    for pkg_name, pkg_desc in packages:
        if pkg_name in installed:
            choices.append((pkg_name, f"✅ {pkg_name} - {pkg_desc} (installed)"))
        else:
            choices.append((pkg_name, f"📦 {pkg_name} - {pkg_desc}"))

    console.print("[yellow]Note:[/yellow] ✅ = already installed, 📦 = not installed")
    console.print()
    display_info("Use ↑↓ arrows to navigate")
    display_info("Press Space to select/deselect")
    display_info("Press Enter when done")
    console.print()

    selected = prompt_checkbox(
        "Select packages to install (skip already installed):",
        choices,
    )

    console.print()
    if selected:
        # Filter out already installed
        not_installed = [pkg for pkg in selected if pkg not in installed]
        already_installed = [pkg for pkg in selected if pkg in installed]

        if already_installed:
            display_info(f"Skipping already installed: {', '.join(already_installed)}")

        if not_installed:
            display_success(f"Will install {len(not_installed)} package(s):")
            for pkg in not_installed:
                console.print(f"  📦 {pkg}")
        else:
            display_warning("All selected packages are already installed.")
    else:
        display_warning("No packages selected")

    console.print("\n[dim]Press Enter to continue...[/dim]")
    input()


def demo_comparison():
    """Demo: Comparison between different input methods"""
    clear_screen()
    console.print(create_header(
        "📊 Input Methods Comparison",
        "Compare different ways to select packages"
    ))
    console.print()

    # Method 1: Text input (old way)
    console.print("[bold]Method 1: Plain Text Input[/bold] (Old)")
    console.print("  • User types: 'neovim tmux git'")
    console.print("  • Pros: Fast if you know exact names")
    console.print("  • Cons: Easy to mistype, no discovery")
    console.print()

    # Method 2: Autocomplete
    console.print("[bold]Method 2: Autocomplete[/bold] (New)")
    console.print("  • User types with suggestions")
    console.print("  • Pros: Fuzzy search, prevents typos")
    console.print("  • Cons: Still text-based")
    console.print()

    # Method 3: Multi-select
    console.print("[bold]Method 3: Multi-Select Checkbox[/bold] (New)")
    console.print("  • User navigates with arrow keys")
    console.print("  • Pros: Visual, discoverable, error-free")
    console.print("  • Cons: Slower for power users")
    console.print()

    console.print("[bold cyan]Which method would you like to try?[/bold cyan]\n")

    method = prompt_select(
        "Select input method:",
        [
            ("autocomplete", "🔍 Autocomplete (single)"),
            ("autocomplete_multi", "🔍 Autocomplete (multiple)"),
            ("checkbox", "☑️  Multi-select checkbox"),
            ("back", "← Back to main menu"),
        ],
        default="checkbox"
    )

    console.print()

    if method == "autocomplete":
        demo_autocomplete()
    elif method == "autocomplete_multi":
        demo_autocomplete_multi()
    elif method == "checkbox":
        demo_checkbox()


def demo_real_world():
    """Demo: Real-world scenario"""
    clear_screen()
    console.print(create_header(
        "🌍 Real-World Scenario",
        "Setting up a development environment"
    ))
    console.print()

    console.print("[bold]Scenario:[/bold] You want to set up a web development environment")
    console.print()

    # Step 1: Choose category
    category = prompt_select(
        "What type of development?",
        [
            ("web", "🌐 Web Development (Node.js, npm, etc.)"),
            ("python", "🐍 Python Development (pip, venv, etc.)"),
            ("devops", "🔧 DevOps (Docker, K8s, etc.)"),
            ("all", "📦 All of the above"),
        ],
        default="web"
    )

    # Step 2: Multi-select packages based on category
    if category == "web":
        choices = [
            ("nodejs", "Node.js - JavaScript runtime"),
            ("npm", "npm - Package manager"),
            ("yarn", "Yarn - Alternative package manager"),
            ("vscode", "VS Code - Code editor"),
            ("firefox", "Firefox - For testing"),
            ("chromium", "Chromium - For testing"),
        ]
    elif category == "python":
        choices = [
            ("python", "Python - Programming language"),
            ("python-pip", "pip - Python package manager"),
            ("python-poetry", "Poetry - Dependency management"),
            ("python-virtualenv", "virtualenv - Virtual environments"),
            ("neovim", "Neovim - Text editor"),
        ]
    elif category == "devops":
        choices = [
            ("docker", "Docker - Containers"),
            ("docker-compose", "Docker Compose - Multi-container apps"),
            ("kubectl", "kubectl - Kubernetes CLI"),
            ("terraform", "Terraform - Infrastructure as code"),
            ("ansible", "Ansible - Configuration management"),
        ]
    else:
        choices = [
            ("nodejs", "Node.js"),
            ("python", "Python"),
            ("docker", "Docker"),
            ("git", "Git"),
            ("vscode", "VS Code"),
        ]

    console.print()
    selected = prompt_checkbox(
        "Select packages to install:",
        choices,
    )

    console.print()
    if selected:
        display_success(f"✅ Selected {len(selected)} package(s) for installation:")
        for pkg in selected:
            console.print(f"   📦 {pkg}")
        console.print()
        console.print("[dim]In real app, these would be installed now...[/dim]")
    else:
        display_warning("No packages selected")

    console.print("\n[dim]Press Enter to continue...[/dim]")
    input()


def main():
    """Main demo menu"""
    while True:
        clear_screen()
        console.print(create_header(
            "🎨 Autocomplete & Multi-Select Demo",
            "Interactive demos of new UI features"
        ))
        console.print()

        choice = prompt_select(
            "Select a demo:",
            [
                ("1", "🔍 Autocomplete (single package)"),
                ("2", "🔍 Autocomplete (multiple packages)"),
                ("3", "☑️  Multi-select checkbox"),
                ("4", "📊 Compare input methods"),
                ("5", "🌍 Real-world scenario"),
                ("0", "❌ Exit"),
            ],
            default="0"
        )

        if choice == "1":
            demo_autocomplete()
        elif choice == "2":
            demo_autocomplete_multi()
        elif choice == "3":
            demo_checkbox()
        elif choice == "4":
            demo_comparison()
        elif choice == "5":
            demo_real_world()
        elif choice == "0":
            console.print()
            display_success("Thanks for trying the demo! 🎉")
            break


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        console.print("\n")
        display_success("Interrupted. Goodbye! 👋")
        sys.exit(0)
