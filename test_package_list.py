#!/usr/bin/env python3
"""
Integration test for package list loading
Tests the full chain: Python -> Bridge -> Zsh -> JSON parsing
"""

from __future__ import annotations

import sys
from pathlib import Path

# Add project root to Python path
PROJECT_ROOT = Path(__file__).parent
sys.path.insert(0, str(PROJECT_ROOT))

from bridge.backend import BackendCaller
from rich.console import Console

console = Console()


def test_list_available_packages():
    """Test loading available packages"""
    print("\n" + "=" * 70)
    print("Test: List Available Packages")
    print("=" * 70)

    try:
        backend = BackendCaller()
        console.print("[cyan]Loading available packages...[/cyan]")

        response = backend.list_available_packages(timeout=30)

        if response.is_success():
            packages = response.data.get("packages", [])
            print(f"✅ SUCCESS: Loaded {len(packages)} packages")
            print(f"   First 10: {', '.join(packages[:10])}")
            print(f"   Last 10: {', '.join(packages[-10:])}")
            return True
        else:
            print(f"❌ FAILED: {response.message}")
            return False

    except Exception as e:
        print(f"❌ ERROR: {e}")
        import traceback
        traceback.print_exc()
        return False


def test_list_installed_packages():
    """Test loading installed packages"""
    print("\n" + "=" * 70)
    print("Test: List Installed Packages")
    print("=" * 70)

    try:
        backend = BackendCaller()
        console.print("[cyan]Loading installed packages...[/cyan]")

        response = backend.list_installed_names(timeout=10)

        if response.is_success():
            packages = response.data.get("packages", [])
            print(f"✅ SUCCESS: Loaded {len(packages)} installed packages")
            if len(packages) > 0:
                print(f"   First 10: {', '.join(packages[:10])}")
            return True
        else:
            print(f"❌ FAILED: {response.message}")
            return False

    except Exception as e:
        print(f"❌ ERROR: {e}")
        import traceback
        traceback.print_exc()
        return False


def test_cache_helpers():
    """Test cache helper functions"""
    print("\n" + "=" * 70)
    print("Test: Cache Helper Functions")
    print("=" * 70)

    try:
        from pkgman import get_available_packages, get_installed_packages

        console.print("[cyan]Testing get_available_packages()...[/cyan]")
        available = get_available_packages()
        print(f"✅ Available packages cached: {len(available)} packages")

        console.print("[cyan]Testing get_installed_packages()...[/cyan]")
        installed = get_installed_packages()
        print(f"✅ Installed packages cached: {len(installed)} packages")

        # Test cache (should be instant)
        console.print("[cyan]Testing cache (second call)...[/cyan]")
        available2 = get_available_packages()
        if available == available2:
            print("✅ Cache working correctly (same data)")
        else:
            print("⚠️  Cache may not be working (different data)")

        return True

    except Exception as e:
        print(f"❌ ERROR: {e}")
        import traceback
        traceback.print_exc()
        return False


def main():
    """Run all tests"""
    print("\n" + "=" * 70)
    print("Package List Integration Tests")
    print("=" * 70)
    print("\nThis tests the full chain:")
    print("  Python UI -> Bridge -> Zsh Backend -> JSON Response\n")

    tests = [
        ("List Available Packages", test_list_available_packages),
        ("List Installed Packages", test_list_installed_packages),
        ("Cache Helper Functions", test_cache_helpers),
    ]

    results = []
    for name, test_func in tests:
        result = test_func()
        results.append((name, result))

    # Summary
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
