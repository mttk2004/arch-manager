#!/usr/bin/env python3
"""
Test script for enhanced installation summary with real package info
"""

from ui.components import display_installation_summary, console, clear_screen, create_header

def test_summary_with_mock_data():
    """Test with mock data (no backend call)"""
    clear_screen()
    console.print(create_header(
        "Test 1: Summary with Mock Data",
        "Testing display without backend calls"
    ))
    console.print()

    packages = ["neovim", "git", "tmux"]
    package_info = {
        "neovim": {
            "description": "Hyperextensible Vim-based text editor",
            "size": "15.2 MiB"
        },
        "git": {
            "description": "Distributed version control system",
            "size": "32.1 MiB"
        },
        "tmux": {
            "description": "Terminal multiplexer",
            "size": "1.8 MiB"
        }
    }

    confirmed = display_installation_summary(packages, package_info, operation="install", fetch_info=False)

    if confirmed:
        console.print("\n[green]✓ User confirmed installation[/green]")
    else:
        console.print("\n[yellow]✗ User cancelled installation[/yellow]")

    console.print()
    input("Press Enter to continue...")


def test_summary_with_backend():
    """Test with real backend calls"""
    clear_screen()
    console.print(create_header(
        "Test 2: Summary with Backend",
        "Fetching real package info from system"
    ))
    console.print()

    # Test with some common packages
    packages = ["bash", "coreutils", "grep"]

    console.print("[cyan]This will fetch real package information from your system...[/cyan]\n")

    confirmed = display_installation_summary(packages, operation="install", fetch_info=True)

    if confirmed:
        console.print("\n[green]✓ User confirmed installation[/green]")
    else:
        console.print("\n[yellow]✗ User cancelled installation[/yellow]")

    console.print()
    input("Press Enter to continue...")


def test_removal_summary():
    """Test removal summary"""
    clear_screen()
    console.print(create_header(
        "Test 3: Removal Summary",
        "Testing removal operation display"
    ))
    console.print()

    packages = ["test-package-1", "test-package-2"]

    confirmed = display_installation_summary(packages, operation="remove", fetch_info=True)

    if confirmed:
        console.print("\n[green]✓ User confirmed removal[/green]")
    else:
        console.print("\n[yellow]✗ User cancelled removal[/yellow]")

    console.print()
    input("Press Enter to continue...")


def main():
    """Run all tests"""
    try:
        console.print("\n[bold cyan]Installation Summary Tests[/bold cyan]\n")
        console.print("This will test the enhanced installation summary feature.\n")
        input("Press Enter to start...")

        # Test 1: Mock data
        test_summary_with_mock_data()

        # Test 2: Real backend (if available)
        try:
            test_summary_with_backend()
        except Exception as e:
            console.print(f"\n[red]Backend test failed: {e}[/red]")
            console.print("[yellow]This is normal if packages don't exist[/yellow]\n")
            input("Press Enter to continue...")

        # Test 3: Removal
        test_removal_summary()

        clear_screen()
        console.print("\n[bold green]✓ All tests completed![/bold green]\n")

    except KeyboardInterrupt:
        console.print("\n\n[yellow]Tests interrupted by user[/yellow]\n")


if __name__ == "__main__":
    main()
