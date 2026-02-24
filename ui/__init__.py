"""
UI Layer - Beautiful terminal user interface using Rich library

This module provides the user interface components for the Arch Zsh Manager,
including menus, tables, progress bars, and interactive prompts.
"""

from ui.components import (
    create_app_header,
    create_grouped_menu,
    create_panel,
    create_table,
    display_error,
    display_installation_summary,
    display_success,
    display_warning,
    install_packages_with_progress,
    remove_packages_with_progress,
    show_progress,
)

__all__ = [
    "create_app_header",
    "create_grouped_menu",
    "create_panel",
    "create_table",
    "display_error",
    "display_installation_summary",
    "display_success",
    "display_warning",
    "install_packages_with_progress",
    "remove_packages_with_progress",
    "show_progress",
]

__version__ = "2.1.0"
