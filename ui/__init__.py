"""
UI Layer - Beautiful terminal user interface using Rich library

This module provides the user interface components for the Arch Zsh Manager,
including menus, tables, progress bars, and interactive prompts.
"""

from ui.components import (
    create_panel,
    create_table,
    display_error,
    display_success,
    display_warning,
    show_progress,
)

__all__ = [
    "create_panel",
    "create_table",
    "display_error",
    "display_success",
    "display_warning",
    "show_progress",
]

__version__ = "2.0.0"
