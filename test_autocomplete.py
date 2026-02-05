#!/usr/bin/env python3
"""
Test script for autocomplete and multi-select integration

Tests:
1. Import verification
2. Function signatures
3. Backend integration
4. Component functionality
"""

from __future__ import annotations

import sys
from pathlib import Path

# Add project root to Python path
PROJECT_ROOT = Path(__file__).parent
sys.path.insert(0, str(PROJECT_ROOT))


def test_imports():
    """Test that all required modules can be imported"""
    print("Testing imports...")

    try:
        import questionary
        print("✅ questionary imported successfully")
    except ImportError as e:
        print(f"❌ Failed to import questionary: {e}")
        return False

    try:
        from prompt_toolkit.completion import FuzzyCompleter, WordCompleter
        print("✅ prompt_toolkit completers imported successfully")
    except ImportError as e:
        print(f"❌ Failed to import prompt_toolkit: {e}")
        return False

    try:
        from ui.components import (
            prompt_autocomplete,
            prompt_autocomplete_multi,
            prompt_checkbox,
        )
        print("✅ UI autocomplete components imported successfully")
    except ImportError as e:
        print(f"❌ Failed to import UI components: {e}")
        return False

    try:
        from bridge.backend import BackendCaller
        print("✅ BackendCaller imported successfully")
    except ImportError as e:
        print(f"❌ Failed to import BackendCaller: {e}")
        return False

    return True


def test_function_signatures():
    """Test that functions have correct signatures"""
    print("\nTesting function signatures...")

    try:
        from ui.components import (
            prompt_autocomplete,
            prompt_autocomplete_multi,
            prompt_checkbox,
        )
        import inspect

        # Test prompt_autocomplete
        sig = inspect.signature(prompt_autocomplete)
        params = list(sig.parameters.keys())
        expected = ['message', 'choices', 'fuzzy', 'default']
        if all(p in params for p in expected):
            print(f"✅ prompt_autocomplete has correct signature: {params}")
        else:
            print(f"❌ prompt_autocomplete missing parameters. Expected: {expected}, Got: {params}")
            return False

        # Test prompt_autocomplete_multi
        sig = inspect.signature(prompt_autocomplete_multi)
        params = list(sig.parameters.keys())
        expected = ['message', 'choices', 'separator']
        if all(p in params for p in expected):
            print(f"✅ prompt_autocomplete_multi has correct signature: {params}")
        else:
            print(f"❌ prompt_autocomplete_multi missing parameters. Expected: {expected}, Got: {params}")
            return False

        # Test prompt_checkbox
        sig = inspect.signature(prompt_checkbox)
        params = list(sig.parameters.keys())
        expected = ['message', 'choices', 'default_selected']
        if all(p in params for p in expected):
            print(f"✅ prompt_checkbox has correct signature: {params}")
        else:
            print(f"❌ prompt_checkbox missing parameters. Expected: {expected}, Got: {params}")
            return False

        return True
    except Exception as e:
        print(f"❌ Failed to inspect functions: {e}")
        return False


def test_backend_methods():
    """Test that BackendCaller has new methods"""
    print("\nTesting BackendCaller methods...")

    try:
        from bridge.backend import BackendCaller
        import inspect

        backend = BackendCaller()

        # Test list_available_packages method exists
        if hasattr(backend, 'list_available_packages'):
            sig = inspect.signature(backend.list_available_packages)
            print(f"✅ list_available_packages method exists: {list(sig.parameters.keys())}")
        else:
            print("❌ list_available_packages method not found")
            return False

        # Test list_installed_names method exists
        if hasattr(backend, 'list_installed_names'):
            sig = inspect.signature(backend.list_installed_names)
            print(f"✅ list_installed_names method exists: {list(sig.parameters.keys())}")
        else:
            print("❌ list_installed_names method not found")
            return False

        return True
    except Exception as e:
        print(f"❌ Failed to test backend methods: {e}")
        return False


def test_questionary_choice():
    """Test questionary Choice creation"""
    print("\nTesting questionary.Choice...")

    try:
        import questionary

        # Test simple choice
        choice = questionary.Choice(title="Test Option", value="test")
        print(f"✅ Created choice: {choice.title} -> {choice.value}")

        # Test choice with checked state
        choice_checked = questionary.Choice(title="Checked", value="checked", checked=True)
        print(f"✅ Created checked choice: {choice_checked.checked}")

        return True
    except Exception as e:
        print(f"❌ Failed to create choice: {e}")
        return False


def test_word_completer():
    """Test WordCompleter creation"""
    print("\nTesting WordCompleter...")

    try:
        from prompt_toolkit.completion import WordCompleter, FuzzyCompleter

        words = ["neovim", "neofetch", "neomutt", "vim", "gvim"]

        # Test WordCompleter
        completer = WordCompleter(words, ignore_case=True)
        print(f"✅ Created WordCompleter with {len(words)} words")

        # Test FuzzyCompleter
        fuzzy = FuzzyCompleter(completer)
        print(f"✅ Created FuzzyCompleter wrapper")

        return True
    except Exception as e:
        print(f"❌ Failed to create completer: {e}")
        return False


def test_cache_helpers():
    """Test package cache helper functions"""
    print("\nTesting cache helpers...")

    try:
        from pkgman import get_available_packages, get_installed_packages

        print("✅ get_available_packages function exists")
        print("✅ get_installed_packages function exists")

        # Check function signatures
        import inspect
        sig1 = inspect.signature(get_available_packages)
        sig2 = inspect.signature(get_installed_packages)

        if 'force_refresh' in sig1.parameters:
            print("✅ get_available_packages has force_refresh parameter")
        else:
            print("⚠️  get_available_packages missing force_refresh parameter")

        if 'force_refresh' in sig2.parameters:
            print("✅ get_installed_packages has force_refresh parameter")
        else:
            print("⚠️  get_installed_packages missing force_refresh parameter")

        return True
    except Exception as e:
        print(f"❌ Failed to test cache helpers: {e}")
        return False


def main():
    """Run all tests"""
    print("=" * 70)
    print("Autocomplete & Multi-Select Integration Tests")
    print("=" * 70)

    tests = [
        ("Imports", test_imports),
        ("Function Signatures", test_function_signatures),
        ("Backend Methods", test_backend_methods),
        ("Questionary Choice", test_questionary_choice),
        ("Word Completer", test_word_completer),
        ("Cache Helpers", test_cache_helpers),
    ]

    results = []
    for name, test in tests:
        print(f"\n{'─' * 70}")
        print(f"Test: {name}")
        print('─' * 70)
        result = test()
        results.append((name, result))

    print("\n" + "=" * 70)
    print("Test Summary")
    print("=" * 70)

    passed = sum(1 for _, result in results if result)
    total = len(results)

    for name, result in results:
        status = "✅ PASSED" if result else "❌ FAILED"
        print(f"{status:12} - {name}")

    print("=" * 70)
    print(f"Total: {passed}/{total} tests passed")

    if passed == total:
        print("\n🎉 All tests passed!")
        return 0
    else:
        print(f"\n⚠️  {total - passed} test(s) failed")
        return 1


if __name__ == "__main__":
    sys.exit(main())
