"""Unit tests for bridge/errors.py"""

from __future__ import annotations

import pytest

from bridge.errors import (
    BackendError,
    BackendNotFoundError,
    BackendPermissionError,
    BackendTimeoutError,
    DependencyError,
    InvalidResponseError,
    PackageNotFoundError,
    SystemError,
    ValidationError,
    parse_backend_error,
)


class TestBackendError:
    """Tests for the base BackendError class."""

    def test_basic_message(self):
        err = BackendError("something failed")
        assert err.message == "something failed"
        assert err.code == "UNKNOWN_ERROR"
        assert err.details == {}

    def test_with_code_and_details(self):
        err = BackendError("fail", code="MY_CODE", details={"key": "val"})
        assert err.code == "MY_CODE"
        assert err.details == {"key": "val"}

    def test_str_without_details(self):
        err = BackendError("fail", code="C")
        assert str(err) == "fail (code: C)"

    def test_str_with_details(self):
        err = BackendError("fail", code="C", details={"x": 1})
        assert "details:" in str(err)

    def test_repr(self):
        err = BackendError("msg", code="C")
        r = repr(err)
        assert "BackendError" in r
        assert "msg" in r

    def test_is_exception(self):
        err = BackendError("x")
        assert isinstance(err, Exception)


class TestBackendTimeoutError:
    def test_defaults(self):
        err = BackendTimeoutError()
        assert err.timeout == 0
        assert "timed out" in err.message

    def test_with_timeout(self):
        err = BackendTimeoutError("timeout!", timeout=30)
        assert err.timeout == 30
        assert "30s" in str(err)

    def test_inherits_backend_error(self):
        err = BackendTimeoutError()
        assert isinstance(err, BackendError)
        assert err.code == "TIMEOUT"


class TestInvalidResponseError:
    def test_defaults(self):
        err = InvalidResponseError()
        assert err.raw_output is None
        assert err.code == "INVALID_RESPONSE"

    def test_with_raw_output(self):
        err = InvalidResponseError("bad json", raw_output="raw data")
        assert "raw data" in str(err)

    def test_truncates_long_output(self):
        long = "x" * 200
        err = InvalidResponseError("bad", raw_output=long)
        assert "..." in str(err)


class TestBackendNotFoundError:
    def test_message(self):
        err = BackendNotFoundError("/some/path")
        assert "/some/path" in str(err)
        assert err.script_path == "/some/path"
        assert err.code == "SCRIPT_NOT_FOUND"


class TestBackendPermissionError:
    def test_does_not_shadow_builtin(self):
        """BackendPermissionError must NOT shadow Python's builtin PermissionError."""
        builtin_err = builtins_PermissionError("test")
        backend_err = BackendPermissionError()
        assert type(builtin_err) is not type(backend_err)
        assert backend_err.code == "PERMISSION_DENIED"

    def test_default_message(self):
        err = BackendPermissionError()
        assert "elevated privileges" in err.message


# Reference to Python builtin PermissionError
builtins_PermissionError = PermissionError


class TestPackageNotFoundError:
    def test_package_name(self):
        err = PackageNotFoundError("vim")
        assert err.package_name == "vim"
        assert "vim" in str(err)
        assert err.code == "PACKAGE_NOT_FOUND"


class TestDependencyError:
    def test_with_conflicting(self):
        err = DependencyError("conflict", conflicting_packages=["a", "b"])
        assert err.conflicting_packages == ["a", "b"]
        assert err.code == "DEPENDENCY_CONFLICT"

    def test_without_conflicting(self):
        err = DependencyError("conflict")
        assert err.conflicting_packages == []


class TestValidationError:
    def test_with_field(self):
        err = ValidationError("bad input", field="name")
        assert err.field == "name"
        assert err.code == "VALIDATION_ERROR"


class TestSystemError:
    def test_with_command(self):
        err = SystemError("failed", command="pacman -S")
        assert err.command == "pacman -S"
        assert err.code == "SYSTEM_ERROR"


class TestParseBackendError:
    def test_timeout(self):
        err = parse_backend_error({"code": "TIMEOUT", "message": "timed out"})
        assert isinstance(err, BackendTimeoutError)

    def test_invalid_response(self):
        err = parse_backend_error({"code": "INVALID_RESPONSE", "message": "bad"})
        assert isinstance(err, InvalidResponseError)

    def test_script_not_found(self):
        err = parse_backend_error({
            "code": "SCRIPT_NOT_FOUND",
            "message": "not found",
            "details": {"path": "/foo"},
        })
        assert isinstance(err, BackendNotFoundError)

    def test_permission_denied(self):
        err = parse_backend_error({"code": "PERMISSION_DENIED", "message": "denied"})
        assert isinstance(err, BackendPermissionError)

    def test_package_not_found(self):
        err = parse_backend_error({
            "code": "PACKAGE_NOT_FOUND",
            "message": "not found",
            "details": {"package": "vim"},
        })
        assert isinstance(err, PackageNotFoundError)

    def test_dependency_conflict(self):
        err = parse_backend_error({
            "code": "DEPENDENCY_CONFLICT",
            "message": "conflict",
            "details": {"conflicting_packages": ["a"]},
        })
        assert isinstance(err, DependencyError)

    def test_validation_error(self):
        err = parse_backend_error({
            "code": "VALIDATION_ERROR",
            "message": "invalid",
            "details": {"field": "name"},
        })
        assert isinstance(err, ValidationError)

    def test_system_error(self):
        err = parse_backend_error({
            "code": "SYSTEM_ERROR",
            "message": "system fail",
            "details": {"command": "cmd"},
        })
        assert isinstance(err, SystemError)

    def test_unknown_code(self):
        err = parse_backend_error({"code": "WHATEVER", "message": "unknown"})
        assert isinstance(err, BackendError)
        assert err.code == "WHATEVER"

    def test_missing_code(self):
        err = parse_backend_error({"message": "oops"})
        assert isinstance(err, BackendError)
        assert err.code == "UNKNOWN_ERROR"

    def test_missing_message(self):
        err = parse_backend_error({"code": "TIMEOUT"})
        assert isinstance(err, BackendTimeoutError)
