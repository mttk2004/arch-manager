"""Unit tests for bridge/backend.py"""

from __future__ import annotations

import json
import subprocess
from pathlib import Path
from unittest.mock import MagicMock, patch

import pytest

from bridge.backend import BackendCaller, _VALID_PACKAGE_NAME
from bridge.errors import (
    BackendError,
    BackendNotFoundError,
    BackendTimeoutError,
    InvalidResponseError,
    ValidationError,
)
from bridge.protocol import StatusType


@pytest.fixture
def tmp_backend_dir(tmp_path):
    """Create a temporary backend directory with stub scripts."""
    backend_dir = tmp_path / "backend"
    backend_dir.mkdir()
    # Create stub scripts
    (backend_dir / "package.zsh").write_text("#!/bin/zsh\necho '{}'\n")
    (backend_dir / "system.zsh").write_text("#!/bin/zsh\necho '{}'\n")
    (backend_dir / "font.zsh").write_text("#!/bin/zsh\necho '{}'\n")
    (backend_dir / "wine.zsh").write_text("#!/bin/zsh\necho '{}'\n")
    return backend_dir


@pytest.fixture
def caller(tmp_backend_dir):
    """Create a BackendCaller instance with temporary backend directory."""
    return BackendCaller(backend_dir=tmp_backend_dir)


# ── Package name validation ──────────────────────────────────────────────────


class TestPackageNameValidation:
    """Tests for package name regex and validation method."""

    @pytest.mark.parametrize("name", [
        "vim",
        "neovim",
        "python3",
        "lib32-mesa",
        "ttf-firacode-nerd",
        "python-pip",
        "gcc.plugin",
        "font_awesome",
        "lua++-dev",
    ])
    def test_valid_names(self, name):
        assert _VALID_PACKAGE_NAME.match(name), f"{name!r} should be valid"

    @pytest.mark.parametrize("name", [
        "",
        "-vim",
        "pkg name",
        "pkg;rm -rf /",
        "pkg$(whoami)",
        "pkg`id`",
        "pkg|cat",
        "pkg&bg",
        "pkg>file",
        "pkg<file",
    ])
    def test_invalid_names(self, name):
        if name == "":
            assert not _VALID_PACKAGE_NAME.match(name)
        else:
            # Names starting with - or containing special shell chars should not match
            match = _VALID_PACKAGE_NAME.match(name)
            if match:
                # Even if regex matches the start, the full string should not match
                assert match.group() != name, f"{name!r} should not fully match"

    def test_validate_package_name_raises_on_empty(self, caller):
        with pytest.raises(ValidationError, match="Invalid package name"):
            caller._validate_package_name("")

    def test_validate_package_name_raises_on_leading_hyphen(self, caller):
        with pytest.raises(ValidationError, match="Invalid package name"):
            caller._validate_package_name("-badname")

    def test_validate_package_name_passes_valid(self, caller):
        # Should not raise
        caller._validate_package_name("vim")
        caller._validate_package_name("python3")
        caller._validate_package_name("lib32-mesa")


# ── BackendCaller initialisation ─────────────────────────────────────────────


class TestBackendCallerInit:
    def test_init_with_valid_dir(self, tmp_backend_dir):
        caller = BackendCaller(backend_dir=tmp_backend_dir)
        assert caller.backend_dir == tmp_backend_dir

    def test_init_with_invalid_dir(self, tmp_path):
        with pytest.raises(BackendNotFoundError):
            BackendCaller(backend_dir=tmp_path / "nonexistent")

    def test_init_with_file_not_dir(self, tmp_path):
        f = tmp_path / "file"
        f.write_text("hi")
        with pytest.raises(BackendError, match="not a directory"):
            BackendCaller(backend_dir=f)

    def test_default_timeout(self, tmp_backend_dir):
        caller = BackendCaller(backend_dir=tmp_backend_dir)
        assert caller.timeout == 300


# ── Script path resolution ───────────────────────────────────────────────────


class TestGetScriptPath:
    def test_existing_module(self, caller, tmp_backend_dir):
        path = caller._get_script_path("package")
        assert path == tmp_backend_dir / "package.zsh"

    def test_nonexistent_module(self, caller):
        with pytest.raises(BackendNotFoundError):
            caller._get_script_path("nonexistent")


# ── Command building ─────────────────────────────────────────────────────────


class TestBuildCommand:
    def test_basic_command(self, caller, tmp_backend_dir):
        script = tmp_backend_dir / "package.zsh"
        cmd = caller._build_command(script, "install", {})
        assert cmd == ["zsh", str(script), "install"]

    def test_packages_list(self, caller, tmp_backend_dir):
        script = tmp_backend_dir / "package.zsh"
        cmd = caller._build_command(script, "install", {"packages": ["vim", "git"]})
        assert "vim" in cmd
        assert "git" in cmd

    def test_packages_string(self, caller, tmp_backend_dir):
        script = tmp_backend_dir / "package.zsh"
        cmd = caller._build_command(script, "info", {"packages": "vim"})
        assert "vim" in cmd

    def test_query_param(self, caller, tmp_backend_dir):
        script = tmp_backend_dir / "package.zsh"
        cmd = caller._build_command(script, "search", {"query": "neovim"})
        assert "neovim" in cmd

    def test_options_bool(self, caller, tmp_backend_dir):
        script = tmp_backend_dir / "package.zsh"
        cmd = caller._build_command(
            script, "install",
            {"options": {"no_confirm": True, "as_deps": False}},
        )
        assert "--no-confirm" in cmd
        assert "--as-deps" not in cmd

    def test_options_value(self, caller, tmp_backend_dir):
        script = tmp_backend_dir / "package.zsh"
        cmd = caller._build_command(
            script, "clean",
            {"options": {"keep_versions": "3"}},
        )
        assert "--keep-versions" in cmd
        assert "3" in cmd

    def test_args_list(self, caller, tmp_backend_dir):
        script = tmp_backend_dir / "system.zsh"
        cmd = caller._build_command(script, "clean_cache", {"args": [3]})
        assert "3" in cmd

    def test_args_single(self, caller, tmp_backend_dir):
        script = tmp_backend_dir / "system.zsh"
        cmd = caller._build_command(script, "clean_cache", {"args": 3})
        assert "3" in cmd

    def test_invalid_package_name_rejected(self, caller, tmp_backend_dir):
        script = tmp_backend_dir / "package.zsh"
        with pytest.raises(ValidationError):
            caller._build_command(script, "install", {"packages": ["-evil"]})


# ── Script execution ─────────────────────────────────────────────────────────


class TestExecuteScript:
    def test_timeout_raises(self, caller):
        with patch("subprocess.run", side_effect=subprocess.TimeoutExpired("cmd", 10)):
            with pytest.raises(BackendTimeoutError):
                caller._execute_script(["echo", "test"], timeout=10)

    def test_generic_error_raises(self, caller):
        with patch("subprocess.run", side_effect=OSError("permission denied")):
            with pytest.raises(BackendError, match="Failed to execute"):
                caller._execute_script(["echo", "test"])


# ── Response parsing ─────────────────────────────────────────────────────────


class TestParseResponse:
    def test_valid_success_response(self, caller):
        result = MagicMock()
        result.stdout = json.dumps({
            "status": "success",
            "data": {"installed": ["vim"]},
            "timestamp": "2024-01-01T00:00:00Z",
        })
        result.stderr = ""
        resp = caller._parse_response(result)
        assert resp.is_success()
        assert resp.data["installed"] == ["vim"]

    def test_invalid_json(self, caller):
        result = MagicMock()
        result.stdout = "not json"
        result.stderr = ""
        with pytest.raises(InvalidResponseError, match="invalid JSON"):
            caller._parse_response(result)

    def test_error_response_raises(self, caller):
        result = MagicMock()
        result.stdout = json.dumps({
            "status": "error",
            "error": {"code": "PACKAGE_NOT_FOUND", "message": "not found", "details": {"package": "vim"}},
            "timestamp": "2024-01-01T00:00:00Z",
        })
        result.stderr = ""
        from bridge.errors import PackageNotFoundError
        with pytest.raises(PackageNotFoundError):
            caller._parse_response(result)

    def test_json_with_extra_output(self, caller):
        """Backend may print extra output before/after JSON; raw_decode handles this."""
        result = MagicMock()
        result.stdout = json.dumps({
            "status": "success",
            "data": {},
            "timestamp": "2024-01-01T00:00:00Z",
        }) + "\nsome extra text"
        result.stderr = ""
        resp = caller._parse_response(result)
        assert resp.is_success()


# ── High-level call method ───────────────────────────────────────────────────


class TestCall:
    def test_call_returns_response(self, caller):
        json_resp = json.dumps({
            "status": "success",
            "data": {"packages": ["vim"]},
            "timestamp": "2024-01-01T00:00:00Z",
        })
        mock_result = MagicMock()
        mock_result.stdout = json_resp
        mock_result.stderr = ""

        with patch.object(caller, "_execute_script", return_value=mock_result):
            resp = caller.call("package", "list_installed")
            assert resp.is_success()


# ── Convenience methods ──────────────────────────────────────────────────────


class TestConvenienceMethods:
    """Test that convenience methods correctly delegate to call()."""

    def _mock_call(self, caller):
        """Patch caller.call to return a success response."""
        from bridge.protocol import Response, StatusType
        mock_resp = Response(
            status=StatusType.SUCCESS,
            data={},
            timestamp="2024-01-01T00:00:00Z",
        )
        return patch.object(caller, "call", return_value=mock_resp)

    def test_install_packages(self, caller):
        with self._mock_call(caller) as mock:
            caller.install_packages(["vim", "git"], no_confirm=True)
            mock.assert_called_once()
            args = mock.call_args
            assert args[0][0] == "package"
            assert args[0][1] == "install"

    def test_remove_packages(self, caller):
        with self._mock_call(caller) as mock:
            caller.remove_packages(["vim"], recursive=True)
            mock.assert_called_once()
            assert args_contain(mock, "package", "remove")

    def test_search_packages(self, caller):
        with self._mock_call(caller) as mock:
            caller.search_packages("vim", aur=True)
            mock.assert_called_once()
            assert args_contain(mock, "package", "search")

    def test_get_package_info(self, caller):
        with self._mock_call(caller) as mock:
            caller.get_package_info("vim")
            mock.assert_called_once()
            assert args_contain(mock, "package", "info")

    def test_list_installed(self, caller):
        with self._mock_call(caller) as mock:
            caller.list_installed()
            assert args_contain(mock, "package", "list_installed")

    def test_list_installed_explicit(self, caller):
        with self._mock_call(caller) as mock:
            caller.list_installed(explicit_only=True)
            assert args_contain(mock, "package", "list_explicit")

    def test_update_system(self, caller):
        with self._mock_call(caller) as mock:
            caller.update_system(aur=True)
            assert args_contain(mock, "package", "update")

    def test_clean_cache(self, caller):
        with self._mock_call(caller) as mock:
            caller.clean_cache(keep_versions=2)
            assert args_contain(mock, "system", "clean_cache")

    def test_remove_orphans(self, caller):
        with self._mock_call(caller) as mock:
            caller.remove_orphans()
            assert args_contain(mock, "system", "remove_orphans")

    def test_check_broken(self, caller):
        with self._mock_call(caller) as mock:
            caller.check_broken()
            assert args_contain(mock, "system", "check_broken")

    def test_list_fonts(self, caller):
        with self._mock_call(caller) as mock:
            caller.list_fonts()
            assert args_contain(mock, "font", "list")

    def test_search_fonts(self, caller):
        with self._mock_call(caller) as mock:
            caller.search_fonts("nerd")
            assert args_contain(mock, "font", "search")

    # Wine methods

    def test_install_wine(self, caller):
        with self._mock_call(caller) as mock:
            caller.install_wine(variant="staging")
            assert args_contain(mock, "wine", "install")

    def test_get_wine_status(self, caller):
        with self._mock_call(caller) as mock:
            caller.get_wine_status()
            assert args_contain(mock, "wine", "status")

    def test_configure_wine_prefix(self, caller):
        with self._mock_call(caller) as mock:
            caller.configure_wine_prefix(arch="win64")
            assert args_contain(mock, "wine", "configure_prefix")

    def test_install_winetricks_component(self, caller):
        with self._mock_call(caller) as mock:
            caller.install_winetricks_component("vcrun2022")
            assert args_contain(mock, "wine", "install_component")

    def test_uninstall_wine(self, caller):
        with self._mock_call(caller) as mock:
            caller.uninstall_wine(remove_prefix=False)
            assert args_contain(mock, "wine", "uninstall")

    # System maintenance extended methods

    def test_update_database(self, caller):
        with self._mock_call(caller) as mock:
            caller.update_database()
            assert args_contain(mock, "system", "update_database")

    def test_get_disk_usage(self, caller):
        with self._mock_call(caller) as mock:
            caller.get_disk_usage()
            assert args_contain(mock, "system", "disk_usage")

    def test_optimize_database(self, caller):
        with self._mock_call(caller) as mock:
            caller.optimize_database()
            assert args_contain(mock, "system", "optimize_database")

    def test_clear_old_logs(self, caller):
        with self._mock_call(caller) as mock:
            caller.clear_old_logs(days=30)
            assert args_contain(mock, "system", "clear_logs")

    def test_downgrade_package(self, caller):
        with self._mock_call(caller) as mock:
            caller.downgrade_package("vim")
            assert args_contain(mock, "system", "downgrade")

    def test_list_cached_versions(self, caller):
        with self._mock_call(caller) as mock:
            caller.list_cached_versions("vim")
            assert args_contain(mock, "system", "list_cached_versions")

    def test_update_mirrors(self, caller):
        with self._mock_call(caller) as mock:
            caller.update_mirrors(country="US", count=10)
            assert args_contain(mock, "system", "update_mirrors")

    def test_get_mirror_status(self, caller):
        with self._mock_call(caller) as mock:
            caller.get_mirror_status()
            assert args_contain(mock, "system", "mirror_status")

    def test_downgrade_validates_name(self, caller):
        """Downgrade should validate the package name."""
        with pytest.raises(ValidationError):
            caller.downgrade_package(";rm -rf /")

    def test_list_cached_validates_name(self, caller):
        """list_cached_versions should validate the package name."""
        with pytest.raises(ValidationError):
            caller.list_cached_versions("pkg$(whoami)")


def args_contain(mock, module, action):
    """Helper: check if mock.call was invoked with the given module and action."""
    args = mock.call_args
    return args[0][0] == module and args[0][1] == action
