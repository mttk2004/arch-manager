"""
Logging configuration for Arch Zsh Manager

Provides centralized logging setup with file and console handlers.
"""

from __future__ import annotations

import logging
import sys
from pathlib import Path
from typing import Optional


def setup_logging(
    level: int = logging.WARNING,
    log_file: Optional[Path] = None,
    debug: bool = False,
) -> None:
    """
    Configure logging for the application.

    Args:
        level: Base logging level (default: WARNING)
        log_file: Optional path to log file
        debug: If True, set level to DEBUG and log to stderr
    """
    if debug:
        level = logging.DEBUG

    root_logger = logging.getLogger()
    root_logger.setLevel(level)

    # Clear existing handlers to avoid duplicates
    root_logger.handlers.clear()

    formatter = logging.Formatter(
        fmt="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )

    if debug:
        # Console handler for debug mode
        console_handler = logging.StreamHandler(sys.stderr)
        console_handler.setLevel(logging.DEBUG)
        console_handler.setFormatter(formatter)
        root_logger.addHandler(console_handler)

    if log_file is not None:
        # File handler
        log_file.parent.mkdir(parents=True, exist_ok=True)
        file_handler = logging.FileHandler(str(log_file), encoding="utf-8")
        file_handler.setLevel(level)
        file_handler.setFormatter(formatter)
        root_logger.addHandler(file_handler)

    if not root_logger.handlers:
        # Add a NullHandler if no handlers configured (library mode)
        root_logger.addHandler(logging.NullHandler())
