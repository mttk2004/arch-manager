"""Unit tests for bridge/protocol.py"""

from __future__ import annotations

import json
from datetime import datetime, timezone

import pytest

from bridge.protocol import (
    ActionType,
    Protocol,
    Request,
    Response,
    StatusType,
    get_data,
    get_error,
    is_success,
    make_install_request,
    make_remove_request,
    make_search_request,
    make_update_request,
)


class TestActionType:
    def test_install_value(self):
        assert ActionType.INSTALL.value == "install"

    def test_all_actions_are_strings(self):
        for action in ActionType:
            assert isinstance(action.value, str)


class TestStatusType:
    def test_values(self):
        assert StatusType.SUCCESS.value == "success"
        assert StatusType.ERROR.value == "error"
        assert StatusType.WARNING.value == "warning"
        assert StatusType.INFO.value == "info"


class TestRequest:
    def test_basic_request(self):
        req = Request(action=ActionType.INSTALL)
        assert req.action == ActionType.INSTALL
        assert req.params == {}
        assert req.metadata == {}

    def test_request_with_params(self):
        req = Request(
            action=ActionType.INSTALL,
            params={"packages": ["vim"]},
        )
        assert req.params["packages"] == ["vim"]

    def test_to_json(self):
        req = Request(action=ActionType.SEARCH, params={"query": "vim"})
        j = req.to_json()
        data = json.loads(j)
        assert data["action"] == "search"
        assert data["params"]["query"] == "vim"

    def test_from_json(self):
        j = '{"action": "install", "params": {"packages": ["vim"]}}'
        req = Request.from_json(j)
        assert req.action == ActionType.INSTALL
        assert req.params["packages"] == ["vim"]

    def test_to_dict(self):
        req = Request(action=ActionType.REMOVE, params={"packages": ["vim"]})
        d = req.to_dict()
        assert d["action"] == "remove"
        assert "packages" in d["params"]

    def test_invalid_params_type(self):
        with pytest.raises(Exception):
            Request(action=ActionType.INSTALL, params="not a dict")


class TestResponse:
    def test_success_response(self):
        resp = Response(status=StatusType.SUCCESS, data={"installed": ["vim"]})
        assert resp.is_success()
        assert not resp.is_error()

    def test_error_response(self):
        resp = Response(
            status=StatusType.ERROR,
            error={"code": "FAIL", "message": "failed"},
        )
        assert resp.is_error()
        assert not resp.is_success()
        assert resp.get_error_code() == "FAIL"
        assert resp.get_error_message() == "failed"

    def test_auto_timestamp(self):
        """Timestamp is auto-generated when explicitly passed as None."""
        resp = Response(status=StatusType.SUCCESS, timestamp=None)
        assert resp.timestamp is not None
        assert resp.timestamp.endswith("Z")

    def test_uses_utc_not_deprecated(self):
        """Ensure timestamp uses timezone-aware UTC (not deprecated utcnow)."""
        resp = Response(status=StatusType.SUCCESS, timestamp=None)
        assert resp.timestamp is not None

    def test_custom_timestamp(self):
        resp = Response(status=StatusType.SUCCESS, timestamp="2024-01-01T00:00:00Z")
        assert resp.timestamp == "2024-01-01T00:00:00Z"

    def test_to_json(self):
        resp = Response(status=StatusType.SUCCESS, data={"key": "val"})
        j = resp.to_json()
        data = json.loads(j)
        assert data["status"] == "success"
        assert data["data"]["key"] == "val"

    def test_from_json(self):
        j = '{"status": "success", "data": {"x": 1}, "timestamp": "2024-01-01T00:00:00Z"}'
        resp = Response.from_json(j)
        assert resp.is_success()
        assert resp.data == {"x": 1}

    def test_to_dict(self):
        resp = Response(status=StatusType.SUCCESS, message="ok")
        d = resp.to_dict()
        assert d["status"] == "success"
        assert d["message"] == "ok"

    def test_get_error_code_none(self):
        resp = Response(status=StatusType.SUCCESS)
        assert resp.get_error_code() is None

    def test_get_error_message_for_error_without_error_dict(self):
        resp = Response(status=StatusType.ERROR, message="generic error")
        assert resp.get_error_message() == "generic error"


class TestProtocol:
    def test_create_request(self):
        req = Protocol.create_request(ActionType.INSTALL, params={"packages": ["vim"]})
        assert req.action == ActionType.INSTALL

    def test_create_request_from_string(self):
        req = Protocol.create_request("install", params={"packages": ["vim"]})
        assert req.action == ActionType.INSTALL

    def test_create_success_response(self):
        resp = Protocol.create_success_response(
            data={"installed": ["vim"]},
            message="Success",
        )
        assert resp.is_success()
        assert resp.data == {"installed": ["vim"]}

    def test_create_error_response(self):
        resp = Protocol.create_error_response(
            error_code="FAIL",
            error_message="failed",
            details={"reason": "not found"},
        )
        assert resp.is_error()
        assert resp.error["code"] == "FAIL"

    def test_parse_response(self):
        j = '{"status": "success", "data": {}, "timestamp": "2024-01-01T00:00:00Z"}'
        resp = Protocol.parse_response(j)
        assert resp.is_success()

    def test_parse_request(self):
        j = '{"action": "search", "params": {"query": "vim"}}'
        req = Protocol.parse_request(j)
        assert req.action == ActionType.SEARCH

    def test_encode_decode_roundtrip(self):
        resp = Protocol.create_success_response(data={"key": "val"}, message="ok")
        encoded = Protocol.encode(resp)
        decoded = Protocol.decode(encoded, response=True)
        assert isinstance(decoded, Response)
        assert decoded.data == {"key": "val"}

    def test_decode_request(self):
        req = Protocol.create_request(ActionType.UPDATE)
        encoded = Protocol.encode(req)
        decoded = Protocol.decode(encoded, response=False)
        assert isinstance(decoded, Request)


class TestConvenienceFunctions:
    def test_make_install_request(self):
        req = make_install_request(["vim", "git"], no_confirm=True)
        assert req.action == ActionType.INSTALL
        assert req.params["packages"] == ["vim", "git"]
        assert req.params["options"]["no_confirm"] is True

    def test_make_remove_request(self):
        req = make_remove_request(["vim"])
        assert req.action == ActionType.REMOVE
        assert req.params["packages"] == ["vim"]

    def test_make_search_request(self):
        req = make_search_request("neovim", aur=True)
        assert req.action == ActionType.SEARCH
        assert req.params["query"] == "neovim"

    def test_make_update_request(self):
        req = make_update_request(aur=True)
        assert req.action == ActionType.UPDATE_SYSTEM

    def test_is_success_response(self):
        resp = Response(status=StatusType.SUCCESS)
        assert is_success(resp)

    def test_is_success_dict(self):
        assert is_success({"status": "success"})
        assert not is_success({"status": "error"})

    def test_get_data_response(self):
        resp = Response(status=StatusType.SUCCESS, data={"x": 1})
        assert get_data(resp) == {"x": 1}

    def test_get_data_dict(self):
        assert get_data({"data": {"x": 1}}) == {"x": 1}

    def test_get_error_response(self):
        resp = Response(
            status=StatusType.ERROR,
            error={"code": "FAIL"},
        )
        assert get_error(resp) == {"code": "FAIL"}

    def test_get_error_dict(self):
        assert get_error({"error": {"code": "FAIL"}}) == {"code": "FAIL"}
