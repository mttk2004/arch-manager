#!/usr/bin/env python3
"""
Simple test to verify questionary menu integration
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
        from ui.components import prompt_select
        print("✅ prompt_select imported successfully")
    except ImportError as e:
        print(f"❌ Failed to import prompt_select: {e}")
        return False

    try:
        from rich.console import Console
        console = Console()
        print("✅ Rich Console imported successfully")
    except ImportError as e:
        print(f"❌ Failed to import Rich: {e}")
        return False

    return True


def test_questionary_choice():
    """Test questionary Choice creation"""
    print("\nTesting questionary.Choice...")

    try:
        import questionary

        choice = questionary.Choice(title="Test Option", value="test")
        print(f"✅ Created choice: {choice.title} -> {choice.value}")
        return True
    except Exception as e:
        print(f"❌ Failed to create choice: {e}")
        return False


def test_prompt_select_function():
    """Test that prompt_select function is properly defined"""
    print("\nTesting prompt_select function...")

    try:
        from ui.components import prompt_select
        import inspect

        sig = inspect.signature(prompt_select)
        params = list(sig.parameters.keys())

        expected_params = ['message', 'choices', 'default']

        if all(p in params for p in expected_params):
            print(f"✅ prompt_select has correct signature: {params}")
            return True
        else:
            print(f"❌ prompt_select missing parameters. Got: {params}")
            return False
    except Exception as e:
        print(f"❌ Failed to inspect prompt_select: {e}")
        return False


def main():
    """Run all tests"""
    print("=" * 60)
    print("Questionary Integration Tests")
    print("=" * 60)

    tests = [
        test_imports,
        test_questionary_choice,
        test_prompt_select_function,
    ]

    results = []
    for test in tests:
        result = test()
        results.append(result)

    print("\n" + "=" * 60)
    print("Test Results")
    print("=" * 60)

    passed = sum(results)
    total = len(results)

    print(f"Passed: {passed}/{total}")

    if passed == total:
        print("✅ All tests passed!")
        return 0
    else:
        print(f"❌ {total - passed} test(s) failed")
        return 1


if __name__ == "__main__":
    sys.exit(main())
