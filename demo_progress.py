#!/usr/bin/env python3
"""
Demo script for progress bars in multi-package operations

This script demonstrates the new progress tracking feature for installing
and removing multiple packages.
"""

from ui.components import (
    console,
    clear_screen,
    create_header,
    display_info,
    display_success,
    display_package_progress,
)


def demo_install_progress():
    """Demo: Installation progress bar"""
    clear_screen()
    console.print(create_header(
        "Demo: Installation Progress Bar",
        "Simulated multi-package installation with progress tracking"
    ))
    console.print()

    packages = ["neovim", "git", "tmux", "docker", "vim"]

    display_info(f"Installing {len(packages)} packages with progress tracking...")

    # Simulate installation with progress
    results = display_package_progress(packages, operation="install", simulate=True)

    display_success("Installation complete!")
    console.print()
    input("Press Enter to continue...")


def demo_remove_progress():
    """Demo: Removal progress bar"""
    clear_screen()
    console.print(create_header(
        "Demo: Removal Progress Bar",
        "Simulated multi-package removal with progress tracking"
    ))
    console.print()

    packages = ["test-pkg-1", "test-pkg-2", "test-pkg-3"]

    display_info(f"Removing {len(packages)} packages with progress tracking...")

    # Simulate removal with progress
    results = display_package_progress(packages, operation="remove", simulate=True)

    display_success("Removal complete!")
    console.print()
    input("Press Enter to continue...")


def demo_progress_features():
    """Demo: Show all progress bar features"""
    clear_screen()
    console.print(create_header(
        "Progress Bar Features",
        "What you'll see in the progress display"
    ))
    console.print()

    console.print("[bold cyan]Progress Bar Components:[/bold cyan]\n")
    console.print("  🔄 [dim]Spinner[/dim] - Shows activity")
    console.print("  📊 [dim]Progress bar[/dim] - Visual completion percentage")
    console.print("  📈 [dim]Percentage[/dim] - Exact completion (e.g., 66%)")
    console.print("  🔢 [dim]Counter[/dim] - Current/Total packages (e.g., 2/3)")
    console.print("  ⏱️  [dim]Elapsed time[/dim] - Time since start")
    console.print()
    console.print("[bold cyan]Package Status Indicators:[/bold cyan]\n")
    console.print("  ✅ [green]Package name[/green] - Successfully installed/removed")
    console.print("  ❌ [red]Package name[/red] - Failed to install/remove")
    console.print("  ⏳ [cyan]Package name[/cyan] - Currently processing")
    console.print()

    input("Press Enter to see it in action...")

    packages = ["pkg-1", "pkg-2", "pkg-3", "pkg-4", "pkg-5"]
    display_package_progress(packages, operation="install", simulate=True)

    console.print()
    input("Press Enter to continue...")


def main():
    """Run all demos"""
    try:
        console.print("\n[bold cyan]Progress Bars Demo[/bold cyan]\n")
        console.print("This demonstrates real-time progress tracking for package operations.\n")
        input("Press Enter to start...")

        # Demo 1: Installation progress
        demo_install_progress()

        # Demo 2: Removal progress
        demo_remove_progress()

        # Demo 3: Feature showcase
        demo_progress_features()

        clear_screen()
        display_success("All demos completed!")
        console.print()
        console.print("[bold]Progress bars will be used automatically when:")
        console.print("  • Installing 2 or more packages")
        console.print("  • Removing 2 or more packages")
        console.print()
        console.print("[dim]Single package operations use a simple spinner instead.[/dim]")
        console.print()

    except KeyboardInterrupt:
        console.print("\n\n[yellow]Demo interrupted by user[/yellow]\n")


if __name__ == "__main__":
    main()
