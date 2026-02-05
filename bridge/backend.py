"""
Backend Caller - Interface for calling Zsh backend scripts from Python

This module provides the main BackendCaller class that handles execution
of Zsh backend scripts and manages the JSON protocol communication.
"""

from __future__ import annotations

import json
import subprocess
from pathlib import Path
from typing import Any, Optional

from bridge.errors import (
    BackendError,
    BackendNotFoundError,
    BackendTimeoutError,
    InvalidResponseError,
    parse_backend_error,
)
from bridge.protocol import ActionType, Protocol, Request, Response


class BackendCaller:
    """
    Interface to call Zsh backend scripts from Python

    This class handles:
    - Locating backend scripts
    - Building command-line arguments
    - Executing scripts via subprocess
    - Parsing JSON responses
    - Error handling and retry logic

    Example:
        >>> backend = BackendCaller()
        >>> response = backend.install_packages(["neovim", "tmux"])
        >>> if response.is_success():
        ...     print(f"Installed: {response.data['installed']}")
    """

    def __init__(
        self,
        backend_dir: Optional[Path] = None,
        timeout: int = 300,
        shell: str = "zsh",
    ) -> None:
        """
        Initialize BackendCaller

        Args:
            backend_dir: Path to backend scripts directory
                         (defaults to lib/backend relative to project root)
            timeout: Default timeout in seconds for backend operations
            shell: Shell to use for executing scripts (default: zsh)
        """
        if backend_dir is None:
            # Auto-detect backend directory
            project_root = Path(__file__).parent.parent
            backend_dir = project_root / "lib" / "backend"

        self.backend_dir = backend_dir
        self.timeout = timeout
        self.shell = shell
        self._validate_backend_dir()

    def _validate_backend_dir(self) -> None:
        """Validate that backend directory exists"""
        if not self.backend_dir.exists():
            raise BackendNotFoundError(str(self.backend_dir))

        if not self.backend_dir.is_dir():
            raise BackendError(
                f"Backend path is not a directory: {self.backend_dir}",
                code="INVALID_BACKEND_PATH",
            )

    def _get_script_path(self, module: str) -> Path:
        """
        Get path to backend script

        Args:
            module: Module name (e.g., 'package', 'system', 'font')

        Returns:
            Path to script file

        Raises:
            BackendNotFoundError: If script doesn't exist
        """
        script_path = self.backend_dir / f"{module}.zsh"

        if not script_path.exists():
            raise BackendNotFoundError(str(script_path))

        return script_path

    def _build_command(
        self,
        script_path: Path,
        action: str,
        params: dict[str, Any],
    ) -> list[str]:
        """
        Build command-line arguments for backend script

        Args:
            script_path: Path to backend script
            action: Action to perform
            params: Action parameters

        Returns:
            List of command arguments
        """
        cmd = [self.shell, str(script_path), action]

        # Add parameters as command-line arguments
        # The backend script will receive these as positional args
        if "packages" in params:
            packages = params["packages"]
            if isinstance(packages, list):
                cmd.extend(packages)
            else:
                cmd.append(str(packages))

        if "query" in params:
            cmd.append(str(params["query"]))

        # Add positional arguments (for system maintenance commands)
        if "args" in params:
            args = params["args"]
            if isinstance(args, list):
                cmd.extend([str(arg) for arg in args])
            else:
                cmd.append(str(args))

        # Add options as flags
        if "options" in params:
            options = params["options"]
            for key, value in options.items():
                if isinstance(value, bool):
                    if value:
                        cmd.append(f"--{key.replace('_', '-')}")
                else:
                    cmd.append(f"--{key.replace('_', '-')}")
                    cmd.append(str(value))

        return cmd

    def _execute_script(
        self,
        cmd: list[str],
        timeout: Optional[int] = None,
    ) -> subprocess.CompletedProcess:
        """
        Execute backend script

        Args:
            cmd: Command and arguments
            timeout: Timeout in seconds (uses default if not specified)

        Returns:
            CompletedProcess result

        Raises:
            BackendTimeoutError: If execution times out
            BackendError: If execution fails
        """
        timeout = timeout or self.timeout

        try:
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=timeout,
                check=False,  # Don't raise on non-zero exit
            )
            return result

        except subprocess.TimeoutExpired as e:
            raise BackendTimeoutError(
                f"Backend script timed out after {timeout}s",
                timeout=timeout,
            ) from e

        except Exception as e:
            raise BackendError(
                f"Failed to execute backend script: {e}",
                code="EXECUTION_FAILED",
            ) from e

    def _parse_response(self, result: subprocess.CompletedProcess) -> Response:
        """
        Parse subprocess result into Response object

        Args:
            result: CompletedProcess from subprocess.run

        Returns:
            Response object

        Raises:
            InvalidResponseError: If response is not valid JSON
            BackendError: If backend returned an error status
        """
        stdout = result.stdout.strip()
        stderr = result.stderr.strip()

        # Try to parse JSON response
        try:
            # Use JSONDecoder to parse first valid JSON object only
            decoder = json.JSONDecoder()
            response_dict, idx = decoder.raw_decode(stdout)
            response = Response(**response_dict)

        except json.JSONDecodeError as e:
            # Invalid JSON - create error response
            raise InvalidResponseError(
                f"Backend returned invalid JSON: {e}",
                raw_output=stdout or stderr,
            ) from e

        except Exception as e:
            raise InvalidResponseError(
                f"Failed to parse backend response: {e}",
                raw_output=stdout,
            ) from e

        # Check if response indicates an error
        if response.is_error() and response.error:
            # Parse and raise specific error type
            raise parse_backend_error(response.error)

        return response

    def call(
        self,
        module: str,
        action: str,
        params: Optional[dict[str, Any]] = None,
        timeout: Optional[int] = None,
    ) -> Response:
        """
        Call a backend script and return parsed response

        Args:
            module: Backend module name (e.g., 'package', 'system')
            action: Action to perform (e.g., 'install', 'remove')
            params: Action parameters
            timeout: Timeout in seconds (uses default if not specified)

        Returns:
            Response object

        Raises:
            BackendNotFoundError: If script doesn't exist
            BackendTimeoutError: If execution times out
            InvalidResponseError: If response is invalid
            BackendError: If backend returns an error

        Example:
            >>> response = backend.call(
            ...     'package',
            ...     'install',
            ...     params={'packages': ['neovim']}
            ... )
        """
        params = params or {}

        # Get script path
        script_path = self._get_script_path(module)

        # Build command
        cmd = self._build_command(script_path, action, params)

        # Execute script
        result = self._execute_script(cmd, timeout)

        # Parse and return response
        return self._parse_response(result)

    # Package Management Methods

    def install_packages(
        self,
        packages: list[str],
        no_confirm: bool = False,
        as_deps: bool = False,
        timeout: Optional[int] = None,
    ) -> Response:
        """
        Install packages

        Args:
            packages: List of package names
            no_confirm: Skip confirmation prompts
            as_deps: Install as dependencies
            timeout: Operation timeout

        Returns:
            Response with installation results
        """
        return self.call(
            "package",
            "install",
            params={
                "packages": packages,
                "options": {
                    "no_confirm": no_confirm,
                    "as_deps": as_deps,
                },
            },
            timeout=timeout,
        )

    def remove_packages(
        self,
        packages: list[str],
        no_confirm: bool = False,
        recursive: bool = False,
        timeout: Optional[int] = None,
    ) -> Response:
        """
        Remove packages

        Args:
            packages: List of package names
            no_confirm: Skip confirmation prompts
            recursive: Remove dependencies
            timeout: Operation timeout

        Returns:
            Response with removal results
        """
        return self.call(
            "package",
            "remove",
            params={
                "packages": packages,
                "options": {
                    "no_confirm": no_confirm,
                    "recursive": recursive,
                },
            },
            timeout=timeout,
        )

    def list_available_packages(
        self,
        timeout: Optional[int] = None,
    ) -> Response:
        """
        Get list of all available package names (for autocomplete)

        Args:
            timeout: Operation timeout

        Returns:
            Response with list of available packages
        """
        return self.call(
            "package",
            "list_available",
            params={},
            timeout=timeout or 30,
        )

    def list_installed_names(
        self,
        timeout: Optional[int] = None,
    ) -> Response:
        """
        Get list of installed package names (for autocomplete in remove)

        Args:
            timeout: Operation timeout

        Returns:
            Response with list of installed package names
        """
        return self.call(
            "package",
            "list_installed_names",
            params={},
            timeout=timeout or 10,
        )

    def search_packages(
        self,
        query: str,
        aur: bool = False,
        timeout: Optional[int] = None,
    ) -> Response:
        """
        Search for packages

        Args:
            query: Search query
            aur: Include AUR packages
            timeout: Operation timeout

        Returns:
            Response with search results
        """
        return self.call(
            "package",
            "search",
            params={
                "query": query,
                "options": {"aur": aur},
            },
            timeout=timeout,
        )

    def get_package_info(
        self,
        package: str,
        timeout: Optional[int] = None,
    ) -> Response:
        """
        Get package information

        Args:
            package: Package name
            timeout: Operation timeout

        Returns:
            Response with package info
        """
        return self.call(
            "package",
            "info",
            params={"packages": [package]},
            timeout=timeout,
        )

    def list_installed(
        self,
        explicit_only: bool = False,
        timeout: Optional[int] = None,
    ) -> Response:
        """
        List installed packages

        Args:
            explicit_only: Only show explicitly installed packages
            timeout: Operation timeout

        Returns:
            Response with package list
        """
        action = "list_explicit" if explicit_only else "list_installed"
        return self.call("package", action, timeout=timeout)

    def update_system(
        self,
        no_confirm: bool = False,
        aur: bool = False,
        timeout: Optional[int] = None,
    ) -> Response:
        """
        Update system packages

        Args:
            no_confirm: Skip confirmation prompts
            aur: Include AUR packages
            timeout: Operation timeout

        Returns:
            Response with update results
        """
        return self.call(
            "package",
            "update",
            params={
                "options": {
                    "no_confirm": no_confirm,
                    "aur": aur,
                },
            },
            timeout=timeout,
        )

    # System Maintenance Methods

    def clean_cache(
        self,
        keep_versions: int = 3,
        timeout: Optional[int] = None,
    ) -> Response:
        """
        Clean package cache

        Args:
            keep_versions: Number of versions to keep
            timeout: Operation timeout

        Returns:
            Response with cleanup results
        """
        return self.call(
            "system",
            "clean_cache",
            params={"args": [keep_versions]},
            timeout=timeout,
        )

    def remove_orphans(
        self,
        no_confirm: bool = False,
        timeout: Optional[int] = None,
    ) -> Response:
        """
        Remove orphaned packages

        Args:
            no_confirm: Skip confirmation prompts
            timeout: Operation timeout

        Returns:
            Response with removal results
        """
        return self.call(
            "system",
            "remove_orphans",
            params={"options": {"no_confirm": no_confirm}},
            timeout=timeout,
        )

    def check_broken(self, timeout: Optional[int] = None) -> Response:
        """
        Check for broken dependencies

        Args:
            timeout: Operation timeout

        Returns:
            Response with broken package list
        """
        return self.call("system", "check_broken", timeout=timeout)

    # Font Management Methods

    def install_fonts(
        self,
        font_type: str,
        fonts: Optional[list[str]] = None,
        timeout: Optional[int] = None,
    ) -> Response:
        """
        Install fonts

        Args:
            font_type: Font type (nerd, system, emoji, cjk, ms)
            fonts: Specific fonts to install (None for all)
            timeout: Operation timeout

        Returns:
            Response with installation results
        """
        return self.call(
            "font",
            "install",
            params={
                "font_type": font_type,
                "fonts": fonts or [],
            },
            timeout=timeout,
        )

    def list_fonts(self, timeout: Optional[int] = None) -> Response:
        """
        List installed fonts

        Args:
            timeout: Operation timeout

        Returns:
            Response with font list
        """
        return self.call("font", "list", timeout=timeout)

    def search_fonts(
        self,
        pattern: str,
        timeout: Optional[int] = None,
    ) -> Response:
        """
        Search for fonts

        Args:
            pattern: Search pattern
            timeout: Operation timeout

        Returns:
            Response with search results
        """
        return self.call(
            "font",
            "search",
            params={"query": pattern},
            timeout=timeout,
        )

    def update_font_cache(self, timeout: Optional[int] = None) -> Response:
        """
        Update font cache

        Args:
            timeout: Operation timeout

        Returns:
            Response with update results
        """
        return self.call("font", "update_cache", timeout=timeout)
