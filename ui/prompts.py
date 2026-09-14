"""
UI Prompts - Interactive prompt and input components

Provides all user-facing input helpers built on top of questionary and
prompt_toolkit:
- Simple text / confirm / choice prompts (via Rich)
- Arrow-key selection menu (questionary select)
- Fuzzy autocomplete (single and multi-value, via prompt_toolkit)
- Multi-select checkbox menu (questionary checkbox)
"""

from __future__ import annotations

from typing import List, Optional

import questionary
from prompt_toolkit.completion import FuzzyCompleter, WordCompleter
from prompt_toolkit.shortcuts import prompt
from questionary import Style
from rich.prompt import Confirm, Prompt

from ui.display import console

# =============================================================================
# Shared questionary style  (matches the Rich colour palette)
# =============================================================================

_QUESTIONARY_STYLE = Style(
    [
        ("qmark", "fg:cyan bold"),  # leading question-mark glyph
        ("question", "fg:cyan bold"),  # question text
        ("answer", "fg:green bold"),  # echoed answer after selection
        ("pointer", "fg:yellow bold"),  # ► cursor
        ("highlighted", "fg:white bold"),  # item under the cursor
        ("selected", "fg:cyan"),  # selected state (select widget)
        ("separator", "fg:blue"),  # list separators
        ("instruction", "fg:cyan"),  # helper text at the bottom
        ("text", "fg:white"),  # default item text
        ("disabled", "fg:#666666 italic"),  # disabled / greyed-out items
        ("checkbox", "fg:green bold"),  # checked checkbox glyph
        ("checkbox-selected", "fg:green bold"),
    ]
)


# =============================================================================
# Simple prompts  (Rich-based)
# =============================================================================


def prompt_text(
    message: str,
    default: str = "",
    password: bool = False,
) -> str:
    """
    Prompt the user for a single line of text input.

    Args:
        message: Prompt label shown to the user
        default: Pre-filled default value (shown in brackets)
        password: When ``True`` the input is masked (for passwords)

    Returns:
        Stripped string entered by the user, or ``default`` if nothing
        was entered
    """
    return Prompt.ask(message, default=default, password=password, console=console)


def prompt_confirm(message: str, default: bool = False) -> bool:
    """
    Ask the user a yes / no question.

    Args:
        message: Question label
        default: Default answer used when the user just presses Enter

    Returns:
        ``True`` if the user confirmed, ``False`` otherwise
    """
    return Confirm.ask(message, default=default, console=console)


def prompt_choice(
    message: str,
    choices: list[str],
    default: Optional[str] = None,
) -> str:
    """
    Prompt the user to type one of the given choices.

    The prompt re-asks until a valid choice is entered.  Use
    :func:`prompt_select` when you prefer arrow-key navigation.

    Args:
        message: Prompt label
        choices: Accepted answer strings (case-sensitive)
        default: Default answer shown in brackets

    Returns:
        The validated choice string entered by the user
    """
    return Prompt.ask(
        message,
        choices=choices,
        default=default,
        console=console,
    )


# =============================================================================
# Arrow-key selection  (questionary select)
# =============================================================================


def prompt_select(
    message: str,
    choices: List[tuple[Optional[str], str]],
    default: Optional[str] = None,
    use_shortcuts: bool = False,
) -> str:
    """
    Present an interactive arrow-key selection menu.

    Each entry in ``choices`` is a ``(value, label)`` pair.  The user
    navigates with ↑/↓ and confirms with Enter.  When
    ``use_shortcuts=True`` the *value* string is also registered as a
    single-key shortcut so the user can jump to an item directly.
    If `value` is None, the `label` is rendered as a Separator.
    """
    questionary_choices = []
    for value, label in choices:
        if value is None:
            questionary_choices.append(questionary.Separator(label))
        elif use_shortcuts:
            questionary_choices.append(
                questionary.Choice(
                    title=label,
                    value=value,
                    shortcut_key=value,
                )
            )
        else:
            questionary_choices.append(questionary.Choice(title=label, value=value))

    result = questionary.select(
        message,
        choices=questionary_choices,
        default=default,
        style=_QUESTIONARY_STYLE,
        qmark="🚀",
        pointer="►",
        use_shortcuts=use_shortcuts,
    ).ask()

    return result if result is not None else (default or "")


# =============================================================================
# Autocomplete prompts  (prompt_toolkit)
# =============================================================================


def prompt_autocomplete(
    message: str,
    choices: List[str],
    fuzzy: bool = True,
    default: str = "",
) -> str:
    """
    Single-value prompt with inline autocomplete / fuzzy matching.

    Suitable for entering a single package name or any value where the
    user should be guided by a list of known completions.

    Args:
        message: Prompt label
        choices: All available completions offered to the user
        fuzzy: Use fuzzy matching when ``True``; prefix matching otherwise
        default: Pre-filled default value

    Returns:
        Stripped string entered by the user, or ``default`` if nothing
        was entered

    Example:
        >>> packages = ["neovim", "neofetch", "neomutt", "vim", "gvim"]
        >>> pkg = prompt_autocomplete("Package name:", packages)
        >>> # Typing "neo" surfaces neovim, neofetch, neomutt
    """
    base_completer = WordCompleter(choices, ignore_case=True)
    completer = FuzzyCompleter(base_completer) if fuzzy else base_completer

    result = prompt(
        f"{message}: ",
        completer=completer,
        default=default,
        complete_while_typing=True,
    )

    return result.strip() if result else default


def prompt_autocomplete_multi(
    message: str,
    choices: List[str],
    separator: str = " ",
) -> List[str]:
    """
    Space-separated multi-value prompt with fuzzy autocomplete.

    The user types several values separated by *separator* in a single
    input line, each individually autocompleted against *choices*.

    Args:
        message: Prompt label
        choices: All available completions offered to the user
        separator: Token separator (default: a single space)

    Returns:
        List of non-empty stripped tokens entered by the user.
        Returns an empty list if the user submits nothing.

    Example:
        >>> packages = ["neovim", "tmux", "git"]
        >>> result = prompt_autocomplete_multi("Packages:", packages)
        >>> # Typing "neovim tmux" returns ["neovim", "tmux"]
    """
    completer = FuzzyCompleter(WordCompleter(choices, ignore_case=True))

    result = prompt(
        f"{message} (space-separated): ",
        completer=completer,
        complete_while_typing=True,
    )

    if result:
        return [item.strip() for item in result.split(separator) if item.strip()]
    return []


# =============================================================================
# Multi-select checkbox  (questionary checkbox)
# =============================================================================


def prompt_checkbox(
    message: str,
    choices: List[tuple[str, str]],
    default_selected: Optional[List[str]] = None,
) -> List[str]:
    """
    Interactive multi-select checkbox menu.

    The user navigates with ↑/↓, toggles items with Space, and
    confirms the whole selection with Enter.

    Args:
        message: Question text shown above the list
        choices: List of ``(value, label)`` tuples to display
        default_selected: Values that should be pre-checked when the
                          menu opens

    Returns:
        List of *value* strings for every checked entry.
        Returns an empty list if the prompt was cancelled.

    Example:
        >>> selected = prompt_checkbox(
        ...     "Select packages to install:",
        ...     [
        ...         ("neovim", "Neovim - Hyperextensible text editor"),
        ...         ("tmux",   "Terminal multiplexer"),
        ...         ("git",    "Version control system"),
        ...     ],
        ... )
        >>> # Returns e.g. ["neovim", "git"] if the user checked those two
    """
    questionary_choices = []
    for value, label in choices:
        checked = bool(default_selected and value in default_selected)
        questionary_choices.append(questionary.Choice(title=label, value=value, checked=checked))

    result = questionary.checkbox(
        message,
        choices=questionary_choices,
        style=_QUESTIONARY_STYLE,
        qmark="📦",
        pointer="►",
        instruction="(Space to select, Enter to confirm)",
    ).ask()

    return result if result is not None else []
