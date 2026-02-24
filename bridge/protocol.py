"""
Protocol Module - JSON-based communication protocol between Python and Zsh

This module defines the request/response protocol and provides utilities
for serialization/deserialization of messages between Python UI and Zsh backend.
"""

from __future__ import annotations

import json
from datetime import datetime, timezone
from enum import Enum
from typing import Any, Optional

from pydantic import BaseModel, Field, field_validator


class ActionType(str, Enum):
    """Available backend actions"""

    # Package Management
    INSTALL = "install"
    REMOVE = "remove"
    UPDATE = "update"
    SEARCH = "search"
    INFO = "info"
    LIST_INSTALLED = "list_installed"
    LIST_EXPLICIT = "list_explicit"

    # System Maintenance
    CLEAN_CACHE = "clean_cache"
    REMOVE_ORPHANS = "remove_orphans"
    CHECK_BROKEN = "check_broken"
    UPDATE_SYSTEM = "update_system"

    # Font Management
    FONT_INSTALL = "font_install"
    FONT_REMOVE = "font_remove"
    FONT_LIST = "font_list"
    FONT_SEARCH = "font_search"
    FONT_UPDATE_CACHE = "font_update_cache"

    # Advanced Features
    DOWNGRADE = "downgrade"
    VIEW_LOGS = "view_logs"
    MIRROR_MANAGEMENT = "mirror_management"
    INSTALL_YAY = "install_yay"

    # Utilities
    CHECK_UPDATES = "check_updates"
    GET_INFO = "get_info"
    VALIDATE = "validate"


class StatusType(str, Enum):
    """Response status types"""

    SUCCESS = "success"
    ERROR = "error"
    WARNING = "warning"
    INFO = "info"


class Request(BaseModel):
    """
    Request message sent from Python to Zsh backend

    Example:
        {
            "action": "install",
            "params": {
                "packages": ["neovim", "tmux"],
                "options": {
                    "no_confirm": false,
                    "as_deps": false
                }
            },
            "metadata": {
                "request_id": "req_123",
                "timestamp": "2024-01-15T10:30:00Z"
            }
        }
    """

    action: ActionType = Field(..., description="Action to perform on backend")
    params: dict[str, Any] = Field(default_factory=dict, description="Action parameters")
    metadata: dict[str, Any] = Field(default_factory=dict, description="Request metadata")

    @field_validator("params")
    @classmethod
    def validate_params(cls, v: dict[str, Any]) -> dict[str, Any]:
        """Ensure params is a dictionary"""
        if not isinstance(v, dict):
            raise ValueError("params must be a dictionary")
        return v

    def to_json(self) -> str:
        """Serialize request to JSON string"""
        return self.model_dump_json(exclude_none=True)

    @classmethod
    def from_json(cls, json_str: str) -> "Request":
        """Deserialize request from JSON string"""
        return cls.model_validate_json(json_str)

    def to_dict(self) -> dict[str, Any]:
        """Convert request to dictionary"""
        return self.model_dump(exclude_none=True)


class Response(BaseModel):
    """
    Response message sent from Zsh backend to Python

    Example Success:
        {
            "status": "success",
            "data": {
                "installed": ["neovim", "tmux"],
                "already_installed": [],
                "failed": []
            },
            "message": "Successfully installed 2 packages",
            "timestamp": "2024-01-15T10:30:15Z"
        }

    Example Error:
        {
            "status": "error",
            "error": {
                "code": "PERMISSION_DENIED",
                "message": "Root privileges required",
                "details": {"command": "pacman -S neovim"}
            },
            "timestamp": "2024-01-15T10:30:15Z"
        }
    """

    status: StatusType = Field(..., description="Response status")
    data: Optional[dict[str, Any]] = Field(None, description="Response data payload")
    error: Optional[dict[str, Any]] = Field(None, description="Error information if status=error")
    message: Optional[str] = Field(None, description="Human-readable message")
    timestamp: Optional[str] = Field(None, description="Response timestamp (ISO 8601)")
    metadata: dict[str, Any] = Field(default_factory=dict, description="Additional metadata")

    @field_validator("timestamp", mode="before")
    @classmethod
    def validate_timestamp(cls, v: Optional[str]) -> Optional[str]:
        """Validate or generate timestamp"""
        if v is None:
            return datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")
        return v

    def to_json(self) -> str:
        """Serialize response to JSON string"""
        return self.model_dump_json(exclude_none=True)

    @classmethod
    def from_json(cls, json_str: str) -> "Response":
        """Deserialize response from JSON string"""
        return cls.model_validate_json(json_str)

    def to_dict(self) -> dict[str, Any]:
        """Convert response to dictionary"""
        return self.model_dump(exclude_none=True)

    def is_success(self) -> bool:
        """Check if response indicates success"""
        return self.status == StatusType.SUCCESS

    def is_error(self) -> bool:
        """Check if response indicates error"""
        return self.status == StatusType.ERROR

    def get_error_code(self) -> Optional[str]:
        """Get error code if present"""
        if self.error:
            return self.error.get("code")
        return None

    def get_error_message(self) -> Optional[str]:
        """Get error message if present"""
        if self.error:
            return self.error.get("message")
        return self.message if self.is_error() else None


class Protocol:
    """
    Protocol handler for encoding/decoding messages

    Provides utilities for creating and parsing request/response objects.
    """

    @staticmethod
    def create_request(
        action: ActionType | str,
        params: Optional[dict[str, Any]] = None,
        **metadata: Any,
    ) -> Request:
        """
        Create a request object

        Args:
            action: Action to perform
            params: Action parameters
            **metadata: Additional metadata fields

        Returns:
            Request object

        Example:
            >>> req = Protocol.create_request(
            ...     ActionType.INSTALL,
            ...     params={"packages": ["neovim"]},
            ...     request_id="req_123"
            ... )
        """
        if isinstance(action, str):
            action = ActionType(action)

        return Request(
            action=action,
            params=params or {},
            metadata=metadata,
        )

    @staticmethod
    def create_success_response(
        data: Optional[dict[str, Any]] = None,
        message: Optional[str] = None,
        **metadata: Any,
    ) -> Response:
        """
        Create a success response object

        Args:
            data: Response data
            message: Success message
            **metadata: Additional metadata

        Returns:
            Response object with status=success
        """
        return Response(
            status=StatusType.SUCCESS,
            data=data,
            message=message,
            metadata=metadata,
        )

    @staticmethod
    def create_error_response(
        error_code: str,
        error_message: str,
        details: Optional[dict[str, Any]] = None,
        **metadata: Any,
    ) -> Response:
        """
        Create an error response object

        Args:
            error_code: Error code
            error_message: Error message
            details: Additional error details
            **metadata: Additional metadata

        Returns:
            Response object with status=error
        """
        return Response(
            status=StatusType.ERROR,
            error={
                "code": error_code,
                "message": error_message,
                "details": details or {},
            },
            message=error_message,
            metadata=metadata,
        )

    @staticmethod
    def parse_response(json_str: str) -> Response:
        """
        Parse JSON string into Response object

        Args:
            json_str: JSON string from backend

        Returns:
            Response object

        Raises:
            json.JSONDecodeError: If JSON is malformed
            pydantic.ValidationError: If JSON doesn't match Response schema
        """
        return Response.from_json(json_str)

    @staticmethod
    def parse_request(json_str: str) -> Request:
        """
        Parse JSON string into Request object

        Args:
            json_str: JSON string

        Returns:
            Request object

        Raises:
            json.JSONDecodeError: If JSON is malformed
            pydantic.ValidationError: If JSON doesn't match Request schema
        """
        return Request.from_json(json_str)

    @staticmethod
    def encode(obj: Request | Response) -> str:
        """
        Encode request or response to JSON string

        Args:
            obj: Request or Response object

        Returns:
            JSON string
        """
        return obj.to_json()

    @staticmethod
    def decode(json_str: str, response: bool = True) -> Request | Response:
        """
        Decode JSON string to Request or Response

        Args:
            json_str: JSON string
            response: If True, parse as Response; if False, parse as Request

        Returns:
            Request or Response object
        """
        if response:
            return Protocol.parse_response(json_str)
        return Protocol.parse_request(json_str)


# Convenience functions for common operations
def make_install_request(packages: list[str], **options: Any) -> Request:
    """Create install packages request"""
    return Protocol.create_request(
        ActionType.INSTALL,
        params={"packages": packages, "options": options},
    )


def make_remove_request(packages: list[str], **options: Any) -> Request:
    """Create remove packages request"""
    return Protocol.create_request(
        ActionType.REMOVE,
        params={"packages": packages, "options": options},
    )


def make_search_request(query: str, **options: Any) -> Request:
    """Create search packages request"""
    return Protocol.create_request(
        ActionType.SEARCH,
        params={"query": query, "options": options},
    )


def make_update_request(**options: Any) -> Request:
    """Create system update request"""
    return Protocol.create_request(
        ActionType.UPDATE_SYSTEM,
        params={"options": options},
    )


def is_success(response: Response | dict[str, Any]) -> bool:
    """Check if response indicates success"""
    if isinstance(response, dict):
        return response.get("status") == "success"
    return response.is_success()


def get_data(response: Response | dict[str, Any]) -> Optional[dict[str, Any]]:
    """Extract data from response"""
    if isinstance(response, dict):
        return response.get("data")
    return response.data


def get_error(response: Response | dict[str, Any]) -> Optional[dict[str, Any]]:
    """Extract error from response"""
    if isinstance(response, dict):
        return response.get("error")
    return response.error
