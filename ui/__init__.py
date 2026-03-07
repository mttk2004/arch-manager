"""
UI Layer - Beautiful terminal user interface using Rich library

This package provides all user-interface components for Arch Zsh Manager,
organised into focused sub-modules:

    ui.display   — status messages, operation results, layout helpers
    ui.tables    — table / panel / header / menu / tree builders
    ui.prompts   — all interactive prompt and input widgets
    ui.progress  — progress bars, install/remove with progress,
                   installation summary panel
    ui.theme     — colour palette, icons, ASCII art, menu definitions

The top-level ``ui`` package re-exports the most commonly used names so
that callers can do either::

    from ui import display_success, create_header
    from ui.display import display_success          # direct import
    from ui.components import display_success       # legacy shim still works
"""

from __future__ import annotations

# ---------------------------------------------------------------------------
# ui.display
# ---------------------------------------------------------------------------
from ui.display import (
    clear_screen,
    console,
    display_error,
    display_info,
    display_operation_result,
    display_success,
    display_warning,
    pause,
    print_divider,
    print_header,
)

# ---------------------------------------------------------------------------
# ui.progress
# ---------------------------------------------------------------------------
from ui.progress import (
    display_installation_summary,
    display_package_progress,
    install_packages_with_progress,
    remove_packages_with_progress,
    show_progress,
)

# ---------------------------------------------------------------------------
# ui.prompts
# ---------------------------------------------------------------------------
from ui.prompts import (
    prompt_autocomplete,
    prompt_autocomplete_multi,
    prompt_checkbox,
    prompt_choice,
    prompt_confirm,
    prompt_select,
    prompt_text,
)

# ---------------------------------------------------------------------------
# ui.tables
# ---------------------------------------------------------------------------
from ui.tables import (
    create_app_header,
    create_dependency_tree,
    create_grouped_menu,
    create_header,
    create_menu_panel,
    create_package_table,
    create_panel,
    create_search_results_table,
    create_table,
    print_json,
)

__all__ = [
    # display
    "clear_screen",
    "console",
    "display_error",
    "display_info",
    "display_operation_result",
    "display_success",
    "display_warning",
    "pause",
    "print_divider",
    "print_header",
    # tables
    "create_app_header",
    "create_dependency_tree",
    "create_grouped_menu",
    "create_header",
    "create_menu_panel",
    "create_package_table",
    "create_panel",
    "create_search_results_table",
    "create_table",
    "print_json",
    # prompts
    "prompt_autocomplete",
    "prompt_autocomplete_multi",
    "prompt_checkbox",
    "prompt_choice",
    "prompt_confirm",
    "prompt_select",
    "prompt_text",
    # progress
    "display_installation_summary",
    "display_package_progress",
    "install_packages_with_progress",
    "remove_packages_with_progress",
    "show_progress",
]

__version__ = "2.1.0"
