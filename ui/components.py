"""
UI Components - Backward-compatible re-export shim

This module previously contained all UI logic in a single file (~1 250 lines).
It has been refactored into focused sub-modules:

    ui.display   — status messages, operation results, layout helpers
    ui.tables    — table / panel / header / menu / tree builders
    ui.prompts   — all interactive prompt and input widgets
    ui.progress  — progress bars, install/remove with progress,
                   installation summary panel

Every public name that existed in the old components.py is still importable
from this module so that existing call-sites (pkgman.py, etc.) continue to
work without modification.
"""

from __future__ import annotations

# ---------------------------------------------------------------------------
# Re-export from ui.display
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
# Re-export from ui.progress
# ---------------------------------------------------------------------------
from ui.progress import (
    display_installation_summary,
    display_package_progress,
    install_packages_with_progress,
    remove_packages_with_progress,
    show_progress,
)

# ---------------------------------------------------------------------------
# Re-export from ui.prompts
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
# Re-export from ui.tables
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
