"""Unit tests for ui/theme.py and enhanced ui/components.py"""

from __future__ import annotations

from io import StringIO

import pytest
from rich.console import Console
from rich.panel import Panel
from rich.text import Text

from ui.theme import (
    APP_BANNER,
    APP_BANNER_SMALL,
    Colors,
    Icons,
    MenuCategory,
    MENU_ITEMS,
)


# =============================================================================
# Theme Constants
# =============================================================================


class TestColors:
    """Tests for the Colors palette constants."""

    def test_primary_colors_defined(self):
        assert Colors.PRIMARY == "cyan"
        assert Colors.SECONDARY == "bright_blue"
        assert Colors.ACCENT == "magenta"

    def test_status_colors_defined(self):
        assert Colors.SUCCESS == "green"
        assert Colors.ERROR == "red"
        assert Colors.WARNING == "yellow"
        assert Colors.INFO == "cyan"

    def test_border_colors_defined(self):
        assert Colors.BORDER_SUCCESS == "green"
        assert Colors.BORDER_ERROR == "red"
        assert Colors.BORDER_WARNING == "yellow"
        assert Colors.BORDER_INFO == "cyan"

    def test_package_colors_defined(self):
        assert Colors.PKG_NAME == "cyan"
        assert Colors.PKG_VERSION == "green"
        assert Colors.PKG_SIZE == "yellow"

    def test_all_colors_are_strings(self):
        for attr in dir(Colors):
            if not attr.startswith("_"):
                value = getattr(Colors, attr)
                assert isinstance(value, str), f"Colors.{attr} should be a string"


class TestIcons:
    """Tests for the Icons emoji constants."""

    def test_status_icons(self):
        assert Icons.SUCCESS == "✅"
        assert Icons.ERROR == "❌"
        assert "⚠" in Icons.WARNING
        assert "ℹ" in Icons.INFO

    def test_package_icons(self):
        assert Icons.PACKAGE == "📦"
        assert Icons.SEARCH == "🔍"
        assert Icons.CLEAN == "🧹"
        assert Icons.WINE == "🍷"

    def test_ui_icons(self):
        assert Icons.ARROW_RIGHT == "►"
        assert Icons.BULLET == "•"
        assert Icons.CHECK == "✓"

    def test_all_icons_are_strings(self):
        for attr in dir(Icons):
            if not attr.startswith("_"):
                value = getattr(Icons, attr)
                assert isinstance(value, str), f"Icons.{attr} should be a string"


class TestAppBanner:
    """Tests for the ASCII art banners."""

    def test_banner_is_string(self):
        assert isinstance(APP_BANNER, str)
        assert isinstance(APP_BANNER_SMALL, str)

    def test_banner_contains_box_art(self):
        """Banner should contain ASCII art characters (the figlet rendering)."""
        # The banner renders "Arch Man" in ASCII art - check for signature patterns
        assert "/ \\" in APP_BANNER  # Part of the 'A' in ASCII art
        assert "| |" in APP_BANNER  # Common in ASCII art letters

    def test_banner_small_contains_version(self):
        assert "2.1.0" in APP_BANNER_SMALL

    def test_banner_has_box_drawing(self):
        assert "╔" in APP_BANNER
        assert "╚" in APP_BANNER

    def test_banner_no_leading_trailing_newline(self):
        assert not APP_BANNER.startswith("\n")
        assert not APP_BANNER.endswith("\n")


class TestMenuItems:
    """Tests for menu category definitions."""

    def test_categories_defined(self):
        assert MenuCategory.PACKAGE_MANAGEMENT == "Package Management"
        assert MenuCategory.SYSTEM_MAINTENANCE == "System Maintenance"
        assert MenuCategory.OTHER == "Other"

    def test_menu_items_has_all_categories(self):
        assert MenuCategory.PACKAGE_MANAGEMENT in MENU_ITEMS
        assert MenuCategory.SYSTEM_MAINTENANCE in MENU_ITEMS
        assert MenuCategory.OTHER in MENU_ITEMS

    def test_menu_items_have_correct_structure(self):
        """Each menu item should be a tuple of (key, label, description)."""
        for category, items in MENU_ITEMS.items():
            assert isinstance(items, list), f"{category} should be a list"
            for item in items:
                assert len(item) == 3, f"Item {item} should have 3 elements"
                key, label, description = item
                assert isinstance(key, str)
                assert isinstance(label, str)
                assert isinstance(description, str)

    def test_menu_keys_unique(self):
        all_keys = []
        for items in MENU_ITEMS.values():
            for key, _, _ in items:
                all_keys.append(key)
        assert len(all_keys) == len(set(all_keys)), "Menu keys must be unique"

    def test_exit_option_exists(self):
        """There should be an exit option with key '0'."""
        other_items = MENU_ITEMS[MenuCategory.OTHER]
        keys = [key for key, _, _ in other_items]
        assert "0" in keys


# =============================================================================
# Enhanced UI Components
# =============================================================================


class TestDisplayFunctions:
    """Tests for the enhanced display functions that use panels."""

    @pytest.fixture(autouse=True)
    def setup_console(self):
        """Replace module console with a capturing console."""
        import ui.components as uc

        self._original_console = uc.console
        self._buffer = StringIO()
        uc.console = Console(file=self._buffer, force_terminal=True, width=80)
        yield
        uc.console = self._original_console

    def _output(self) -> str:
        return self._buffer.getvalue()

    def test_display_success_renders_panel(self):
        from ui.components import display_success

        display_success("All done")
        output = self._output()
        assert "Success" in output
        assert "All done" in output
        # Panel border characters
        assert "╭" in output or "┌" in output or "─" in output

    def test_display_error_renders_panel(self):
        from ui.components import display_error

        display_error("Something failed", "ERR_CODE")
        output = self._output()
        assert "Error" in output
        assert "Something failed" in output
        assert "ERR_CODE" in output

    def test_display_error_without_code(self):
        from ui.components import display_error

        display_error("Generic failure")
        output = self._output()
        assert "Generic failure" in output

    def test_display_warning_renders_panel(self):
        from ui.components import display_warning

        display_warning("Be careful")
        output = self._output()
        assert "Warning" in output
        assert "Be careful" in output

    def test_display_info_renders_panel(self):
        from ui.components import display_info

        display_info("Loading data")
        output = self._output()
        assert "Info" in output
        assert "Loading data" in output


class TestCreateAppHeader:
    """Tests for the ASCII art header creation."""

    def test_returns_text(self):
        from ui.components import create_app_header

        result = create_app_header()
        assert isinstance(result, Text)

    def test_contains_subtitle(self):
        import ui.components as uc

        old_console = uc.console
        buf = StringIO()
        uc.console = Console(file=buf, force_terminal=True, width=80)
        result = uc.create_app_header()
        uc.console.print(result)
        output = buf.getvalue()
        assert "Package Manager" in output
        uc.console = old_console

    def test_uses_small_banner_for_narrow_terminal(self):
        import ui.components as uc

        old_console = uc.console
        buf = StringIO()
        uc.console = Console(file=buf, force_terminal=True, width=50)
        result = uc.create_app_header()
        uc.console.print(result)
        output = buf.getvalue()
        assert "Arch Manager" in output
        uc.console = old_console


class TestCreateGroupedMenu:
    """Tests for the grouped menu panel."""

    def test_returns_panel(self):
        from ui.components import create_grouped_menu

        result = create_grouped_menu()
        assert isinstance(result, Panel)

    def test_contains_categories(self):
        import ui.components as uc

        old_console = uc.console
        buf = StringIO()
        uc.console = Console(file=buf, force_terminal=True, width=80)
        panel = uc.create_grouped_menu()
        uc.console.print(panel)
        output = buf.getvalue()
        assert "Package Management" in output
        assert "System Maintenance" in output
        assert "Other" in output
        uc.console = old_console

    def test_contains_all_menu_keys(self):
        import ui.components as uc

        old_console = uc.console
        buf = StringIO()
        uc.console = Console(file=buf, force_terminal=True, width=80)
        panel = uc.create_grouped_menu()
        uc.console.print(panel)
        output = buf.getvalue()
        for key in ["[1]", "[2]", "[3]", "[4]", "[5]", "[6]", "[7]", "[8]", "[9]", "[w]", "[0]"]:
            assert key in output, f"Menu should contain key {key}"
        uc.console = old_console


class TestOperationResult:
    """Tests for enhanced operation result display."""

    @pytest.fixture(autouse=True)
    def setup_console(self):
        import ui.components as uc

        self._original_console = uc.console
        self._buffer = StringIO()
        uc.console = Console(file=self._buffer, force_terminal=True, width=80)
        yield
        uc.console = self._original_console

    def _output(self) -> str:
        return self._buffer.getvalue()

    def test_success_result(self):
        from ui.components import display_operation_result

        display_operation_result({
            "status": "success",
            "message": "Done",
            "data": {"installed": ["vim"]},
        })
        output = self._output()
        assert "Done" in output
        assert "vim" in output

    def test_error_result(self):
        from ui.components import display_operation_result

        display_operation_result({
            "status": "error",
            "error": {"code": "FAIL", "message": "Broken"},
        })
        output = self._output()
        assert "Broken" in output

    def test_result_with_failed_packages(self):
        from ui.components import display_operation_result

        display_operation_result({
            "status": "success",
            "message": "Partial",
            "data": {"installed": ["a"], "failed": ["b"]},
        })
        output = self._output()
        assert "Operation Details" in output
        assert "Installed" in output
        assert "Failed" in output


class TestPrintHeader:
    """Tests for the updated print_header function."""

    @pytest.fixture(autouse=True)
    def setup_console(self):
        import ui.components as uc

        self._original_console = uc.console
        self._buffer = StringIO()
        uc.console = Console(file=self._buffer, force_terminal=True, width=80)
        yield
        uc.console = self._original_console

    def test_print_header_renders(self):
        from ui.components import print_header

        print_header("My Section")
        output = self._buffer.getvalue()
        assert "My Section" in output
        # Rule characters
        assert "─" in output
