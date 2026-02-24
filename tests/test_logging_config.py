"""Unit tests for bridge/logging_config.py"""

from __future__ import annotations

import logging
from pathlib import Path

from bridge.logging_config import setup_logging


class TestSetupLogging:
    def teardown_method(self):
        """Reset root logger after each test."""
        root = logging.getLogger()
        root.handlers.clear()
        root.setLevel(logging.WARNING)

    def test_default_adds_null_handler(self):
        setup_logging()
        root = logging.getLogger()
        assert any(isinstance(h, logging.NullHandler) for h in root.handlers)

    def test_debug_mode_sets_level(self):
        setup_logging(debug=True)
        root = logging.getLogger()
        assert root.level == logging.DEBUG
        assert any(isinstance(h, logging.StreamHandler) for h in root.handlers)

    def test_file_handler(self, tmp_path):
        log_file = tmp_path / "test.log"
        setup_logging(log_file=log_file)
        root = logging.getLogger()
        assert any(isinstance(h, logging.FileHandler) for h in root.handlers)

        # Write a log message and verify
        test_logger = logging.getLogger("test")
        test_logger.warning("test message")
        content = log_file.read_text()
        assert "test message" in content

    def test_file_handler_creates_parent_dirs(self, tmp_path):
        log_file = tmp_path / "subdir" / "deep" / "test.log"
        setup_logging(log_file=log_file)
        assert log_file.parent.exists()

    def test_no_duplicate_handlers_on_reconfig(self):
        setup_logging(debug=True)
        handler_count_1 = len(logging.getLogger().handlers)
        setup_logging(debug=True)
        handler_count_2 = len(logging.getLogger().handlers)
        assert handler_count_1 == handler_count_2
