"""
UI Display - Status messages and operation result rendering

Provides styled terminal output for success, error, warning, and info states,
as well as structured display of backend operation results.
"""

from __future__ import annotations

from typing import Any, Optional

# =============================================================================
# Console (single global instance shared across ui package)
# =============================================================================
from rich.console import Console
from rich.panel import Panel
from rich.text import Text

from ui.theme import Colors, Icons

console = Console()


# =============================================================================
# Status Messages
# =============================================================================


def display_success(message: str, data: Optional[dict[str, Any]] = None) -> None:
    """
    Display a success message inside a styled panel.

    Args:
        message: Success message to display
        data: Optional extra data dict (printed below the panel in dim style)
    """
    panel = Panel(
        Text(message, style=Colors.SUCCESS),
        title=f"{Icons.SUCCESS} Success",
        title_align="left",
        border_style=Colors.BORDER_SUCCESS,
        padding=(0, 1),
    )
    console.print(panel)

    if data:
        console.print(data, style=Colors.TEXT_DIM)


def display_error(message: str, error_code: Optional[str] = None) -> None:
    """
    Display an error message inside a styled panel.

    Args:
        message: Error message to display
        error_code: Optional error code shown alongside the message
    """
    text = Text(message, style=Colors.ERROR)
    if error_code:
        text.append(f" (Code: {error_code})", style="dim red")

    panel = Panel(
        text,
        title=f"{Icons.ERROR} Error",
        title_align="left",
        border_style=Colors.BORDER_ERROR,
        padding=(0, 1),
    )
    console.print(panel)


def display_warning(message: str) -> None:
    """
    Display a warning message inside a styled panel.

    Args:
        message: Warning message to display
    """
    panel = Panel(
        Text(message, style=Colors.WARNING),
        title=f"{Icons.WARNING} Warning",
        title_align="left",
        border_style=Colors.BORDER_WARNING,
        padding=(0, 1),
    )
    console.print(panel)


def display_info(message: str) -> None:
    """
    Display an informational message inside a styled panel.

    Args:
        message: Info message to display
    """
    panel = Panel(
        Text(message, style=Colors.INFO),
        title=f"{Icons.INFO} Info",
        title_align="left",
        border_style=Colors.BORDER_INFO,
        padding=(0, 1),
    )
    console.print(panel)


# =============================================================================
# Operation Result
# =============================================================================


def display_operation_result(response: dict[str, Any]) -> None:
    """
    Display the result of a backend operation with a styled summary panel.

    Dispatches to display_success / display_error / display_warning /
    display_info based on the ``status`` field in the response dict.
    If the response data contains lists of installed/removed/failed packages,
    they are rendered in a secondary "Operation Details" panel.

    Args:
        response: Response dictionary from backend (as produced by
                  ``Response.to_dict()``)
    """
    status = response.get("status", "unknown")
    message = response.get("message", "Operation completed")
    data = response.get("data", {})

    if status == "success":
        display_success(message)
    elif status == "error":
        error = response.get("error", {})
        error_code = error.get("code")
        error_message = error.get("message", message)
        display_error(error_message, error_code)
    elif status == "warning":
        display_warning(message)
    else:
        display_info(message)

    # Render a secondary details panel for any status that carries
    # package-level installed / removed / failed lists.
    # This covers success, warning, and partial-failure responses alike.
    if not data or not isinstance(data, dict):
        return

    details = Text()
    has_details = False

    if data.get("installed"):
        has_details = True
        details.append(f"\n  {Icons.SUCCESS} Installed: ", style=Colors.SUCCESS_BOLD)
        details.append(", ".join(data["installed"]), style=Colors.SUCCESS)

    if data.get("optional_installed"):
        has_details = True
        details.append(f"\n  {Icons.SUCCESS} Optional deps installed: ", style=Colors.SUCCESS_BOLD)
        details.append(", ".join(data["optional_installed"]), style=Colors.SUCCESS)

    if data.get("removed"):
        has_details = True
        details.append(f"\n  {Icons.SUCCESS} Removed: ", style=Colors.WARNING_BOLD)
        details.append(", ".join(data["removed"]), style=Colors.WARNING)

    if data.get("failed"):
        has_details = True
        details.append(f"\n  {Icons.ERROR} Failed: ", style=Colors.ERROR_BOLD)
        details.append(", ".join(data["failed"]), style=Colors.ERROR)
        details.append(
            "\n\n  [dim]Tip: run the operation again or install failed packages manually.[/dim]",
            style="",
        )

    if has_details:
        # Use a warning border when there are failures, otherwise dim
        border = Colors.BORDER_WARNING if data.get("failed") else Colors.TEXT_DIM
        console.print(
            Panel(
                details,
                title="Operation Details",
                title_align="left",
                border_style=border,
                padding=(0, 1),
            )
        )


# =============================================================================
# Layout Helpers
# =============================================================================


def print_divider(style: str = Colors.TEXT_DIM) -> None:
    """
    Print a full-width horizontal rule.

    Args:
        style: Rich style string applied to the rule
    """
    from rich.rule import Rule

    console.print(Rule(style=style))


def print_header(text: str, style: str = Colors.PRIMARY_BOLD) -> None:
    """
    Print a titled horizontal rule as a section separator.

    Args:
        text: Title text embedded in the rule
        style: Rich style string applied to the rule
    """
    from rich.rule import Rule

    console.print()
    console.print(Rule(title=text, style=style))
    console.print()


def clear_screen() -> None:
    """Clear the terminal screen."""
    console.clear()


def pause(message: str = "Press Enter to continue...") -> None:
    """
    Pause execution and wait for the user to press Enter.

    Args:
        message: Prompt message displayed before waiting
    """
    console.print(f"\n{message}", style="dim")
    input()
