"""
Bridge Layer - Communication between Python UI and Zsh Backend

This module provides the interface for Python code to call Zsh backend scripts
and handle JSON-based request/response protocol.
"""

from bridge.backend import BackendCaller
from bridge.errors import BackendError, BackendTimeoutError, InvalidResponseError
from bridge.protocol import Protocol, Request, Response

__all__ = [
    "BackendCaller",
    "BackendError",
    "BackendTimeoutError",
    "InvalidResponseError",
    "Protocol",
    "Request",
    "Response",
]

__version__ = "2.1.0"
