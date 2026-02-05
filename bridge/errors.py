"""
Error handling for bridge layer

Custom exceptions for Python-Zsh communication errors.
"""

from __future__ import annotations

from typing import Any, Optional


class BackendError(Exception):
    """Base exception for backend-related errors"""

    def __init__(
        self,
        message: str,
        code: Optional[str] = None,
        details: Optional[dict[str, Any]] = None,
    ) -> None:
        super().__init__(message)
        self.message = message
        self.code = code or "UNKNOWN_ERROR"
        self.details = details or {}

    def __str__(self) -> str:
        if self.details:
            return f"{self.message} (code: {self.code}, details: {self.details})"
        return f"{self.message} (code: {self.code})"

    def __repr__(self) -> str:
        return (
            f"BackendError(message={self.message!r}, "
            f"code={self.code!r}, details={self.details!r})"
        )


class BackendTimeoutError(BackendError):
    """Raised when backend script execution times out"""

    def __init__(self, message: str = "Backend operation timed out", timeout: int = 0) -> None:
        super().__init__(message, code="TIMEOUT")
        self.timeout = timeout

    def __str__(self) -> str:
        if self.timeout:
            return f"{self.message} after {self.timeout}s"
        return self.message


class InvalidResponseError(BackendError):
    """Raised when backend returns invalid or malformed response"""

    def __init__(
        self,
        message: str = "Invalid response from backend",
        raw_output: Optional[str] = None,
    ) -> None:
        super().__init__(message, code="INVALID_RESPONSE")
        self.raw_output = raw_output

    def __str__(self) -> str:
        if self.raw_output:
            preview = (
                self.raw_output[:100] + "..."
                if len(self.raw_output) > 100
                else self.raw_output
            )
            return f"{self.message}\nRaw output: {preview}"
        return self.message


class BackendNotFoundError(BackendError):
    """Raised when backend script file is not found"""

    def __init__(self, script_path: str) -> None:
        super().__init__(
            f"Backend script not found: {script_path}",
            code="SCRIPT_NOT_FOUND",
        )
        self.script_path = script_path


class PermissionError(BackendError):
    """Raised when backend operation requires elevated privileges"""

    def __init__(self, message: str = "Operation requires elevated privileges") -> None:
        super().__init__(message, code="PERMISSION_DENIED")


class PackageNotFoundError(BackendError):
    """Raised when package is not found in repositories"""

    def __init__(self, package_name: str) -> None:
        super().__init__(
            f"Package not found: {package_name}",
            code="PACKAGE_NOT_FOUND",
        )
        self.package_name = package_name


class DependencyError(BackendError):
    """Raised when there are dependency conflicts"""

    def __init__(
        self,
        message: str,
        conflicting_packages: Optional[list[str]] = None,
    ) -> None:
        super().__init__(message, code="DEPENDENCY_CONFLICT")
        self.conflicting_packages = conflicting_packages or []


class ValidationError(BackendError):
    """Raised when input validation fails"""

    def __init__(self, message: str, field: Optional[str] = None) -> None:
        super().__init__(message, code="VALIDATION_ERROR")
        self.field = field


class SystemError(BackendError):
    """Raised when system-level error occurs"""

    def __init__(self, message: str, command: Optional[str] = None) -> None:
        super().__init__(message, code="SYSTEM_ERROR")
        self.command = command


def parse_backend_error(error_data: dict[str, Any]) -> BackendError:
    """
    Parse error response from backend and return appropriate exception

    Args:
        error_data: Error dictionary from backend JSON response

    Returns:
        Appropriate BackendError subclass instance
    """
    code = error_data.get("code", "UNKNOWN_ERROR")
    message = error_data.get("message", "Unknown error occurred")
    details = error_data.get("details", {})

    error_map = {
        "TIMEOUT": lambda: BackendTimeoutError(message),
        "INVALID_RESPONSE": lambda: InvalidResponseError(message),
        "SCRIPT_NOT_FOUND": lambda: BackendNotFoundError(details.get("path", "unknown")),
        "PERMISSION_DENIED": lambda: PermissionError(message),
        "PACKAGE_NOT_FOUND": lambda: PackageNotFoundError(details.get("package", "unknown")),
        "DEPENDENCY_CONFLICT": lambda: DependencyError(
            message, details.get("conflicting_packages")
        ),
        "VALIDATION_ERROR": lambda: ValidationError(message, details.get("field")),
        "SYSTEM_ERROR": lambda: SystemError(message, details.get("command")),
    }

    error_factory = error_map.get(code)
    if error_factory:
        return error_factory()

    # Default to generic BackendError
    return BackendError(message, code=code, details=details)
