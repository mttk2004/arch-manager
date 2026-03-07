"""
UI Progress - Progress bars and package operation progress tracking

Provides Rich-based progress display for long-running operations,
as well as higher-level helpers that drive install/remove operations
package-by-package with live progress feedback.
"""

from __future__ import annotations

import logging
import subprocess
from typing import TYPE_CHECKING, Any, List, Optional

from rich.panel import Panel
from rich.progress import (
    BarColumn,
    Progress,
    SpinnerColumn,
    TaskID,
    TextColumn,
    TimeElapsedColumn,
)

from ui.display import console
from ui.theme import Colors, Icons

if TYPE_CHECKING:
    from bridge.backend import BackendCaller

logger = logging.getLogger(__name__)


# =============================================================================
# Generic Progress Bar
# =============================================================================


def show_progress(
    description: str = "Working...",
    total: Optional[int] = None,
) -> tuple[Progress, TaskID]:
    """
    Create a Rich progress bar (not yet started).

    The caller is responsible for starting and stopping the returned
    ``Progress`` context, or using it as a context manager.

    Args:
        description: Text displayed next to the spinner / bar
        total: Number of steps (``None`` for an indeterminate bar)

    Returns:
        ``(Progress, TaskID)`` — the progress instance and the ID of
        the single task that was added to it

    Example:
        >>> progress, task = show_progress("Installing packages", total=3)
        >>> with progress:
        ...     for i in range(3):
        ...         progress.update(task, advance=1)
    """
    progress = Progress(
        SpinnerColumn(),
        TextColumn("[progress.description]{task.description}"),
        BarColumn(),
        TextColumn("[progress.percentage]{task.percentage:>3.0f}%"),
        TimeElapsedColumn(),
        console=console,
    )
    task = progress.add_task(description, total=total)
    return progress, task


# =============================================================================
# Package-level Progress Display  (simulation / testing helper)
# =============================================================================


def display_package_progress(
    packages: List[str],
    operation: str = "install",
    simulate: bool = False,
) -> dict[str, Any]:
    """
    Render a progress bar while iterating over a package list.

    When ``simulate=True`` each step sleeps for one second so the
    progress bar can be observed without a real backend.  In normal
    usage (``simulate=False``) the function marks every package as
    ``"pending"`` — actual backend calls are handled at a higher level
    by :func:`install_packages_with_progress` /
    :func:`remove_packages_with_progress`.

    Args:
        packages: Ordered list of package names to process
        operation: ``"install"`` or ``"remove"`` (affects displayed text)
        simulate: Run in simulation mode (adds artificial 1-second delay)

    Returns:
        Dict mapping each package name to ``{"status": "success"}``
        (simulate) or ``{"status": "pending"}`` (live mode)
    """
    import time

    results: dict[str, Any] = {}
    total = len(packages)
    action = "Installing" if operation == "install" else "Removing"

    progress = Progress(
        SpinnerColumn(),
        TextColumn("[bold blue]{task.description}"),
        BarColumn(),
        TextColumn("[progress.percentage]{task.percentage:>3.0f}%"),
        TextColumn("•"),
        TextColumn("{task.completed}/{task.total}"),
        TimeElapsedColumn(),
        console=console,
    )

    console.print()

    with progress:
        task = progress.add_task(f"[cyan]{action} packages...", total=total)

        for idx, pkg in enumerate(packages, 1):
            progress.update(
                task,
                description=f"[cyan]{action} {pkg}...",
                completed=idx - 1,
            )

            # Echo completion of the previous package
            if idx > 1:
                prev_pkg = packages[idx - 2]
                console.print(f"  {Icons.SUCCESS} [green]{prev_pkg}[/green] - {operation}ed")

            if simulate:
                time.sleep(1)
                results[pkg] = {"status": "success"}
            else:
                results[pkg] = {"status": "pending"}

            progress.update(task, completed=idx)

        # Echo last package
        if packages:
            console.print(f"  {Icons.SUCCESS} [green]{packages[-1]}[/green] - {operation}ed")

    console.print()
    return results


# =============================================================================
# Install with Progress
# =============================================================================


def install_packages_with_progress(
    packages: List[str],
    backend: "BackendCaller",
    as_deps: bool = False,
    debug: bool = False,
) -> tuple[List[str], List[str]]:
    """
    Install packages one-by-one with a live Rich progress bar.

    Each package is installed individually so that the progress bar can
    reflect per-package success or failure.  After the backend reports
    success for a package, ``pacman -Q`` is run as a double-check to
    confirm the package is actually present.

    Args:
        packages: Ordered list of package names to install
        backend: Initialised :class:`~bridge.backend.BackendCaller` instance
        as_deps: When ``True`` packages are marked as dependencies
                 (passes ``--asdeps`` to pacman)
        debug: Emit extra debug lines to the console when ``True``

    Returns:
        ``(successful, failed)`` — two lists of package names partitioned
        by whether installation succeeded or failed
    """
    success: List[str] = []
    failed: List[str] = []
    total = len(packages)

    progress = Progress(
        SpinnerColumn(),
        TextColumn("[bold blue]{task.description}"),
        BarColumn(complete_style="green", finished_style="bold green"),
        TextColumn("[progress.percentage]{task.percentage:>3.0f}%"),
        TextColumn("•"),
        TextColumn("{task.completed}/{task.total}"),
        TimeElapsedColumn(),
        console=console,
    )

    console.print()

    with progress:
        task = progress.add_task("[cyan]Installing packages...", total=total)

        for idx, pkg in enumerate(packages, 1):
            progress.update(
                task,
                description=f"[cyan]Installing {pkg}...",
                completed=idx - 1,
            )

            try:
                if debug:
                    console.print(f"[dim]DEBUG: Installing {pkg}...[/dim]")

                response = backend.install_packages([pkg], no_confirm=True, as_deps=as_deps)

                if response.is_success():
                    # Double-check: pacman -Q confirms the package is installed
                    check = subprocess.run(
                        ["pacman", "-Q", pkg],
                        capture_output=True,
                        timeout=5,
                    )
                    if check.returncode == 0:
                        success.append(pkg)
                        console.print(f"  {Icons.SUCCESS} [green]{pkg}[/green] - Installed")
                    else:
                        failed.append(pkg)
                        console.print(
                            f"  {Icons.WARNING} [yellow]{pkg}[/yellow]"
                            " - Installation reported success but package not found"
                        )
                else:
                    failed.append(pkg)
                    error_msg = getattr(response, "message", None) or "Unknown error"
                    console.print(f"  {Icons.ERROR} [red]{pkg}[/red] - Failed: {error_msg}")

            except Exception as exc:  # noqa: BLE001
                failed.append(pkg)
                logger.debug("Exception while installing %s", pkg, exc_info=True)
                console.print(f"  {Icons.ERROR} [red]{pkg}[/red] - Error: {exc}")

            progress.update(task, completed=idx)

    return success, failed


# =============================================================================
# Remove with Progress
# =============================================================================


def remove_packages_with_progress(
    packages: List[str],
    backend: "BackendCaller",
    recursive: bool = False,
    debug: bool = False,
) -> tuple[List[str], List[str]]:
    """
    Remove packages one-by-one with a live Rich progress bar.

    Each package is removed individually so that per-package success or
    failure can be tracked.  After the backend reports success for a
    package, ``pacman -Q`` is run as a double-check to confirm the
    package is actually gone.

    After a successful non-recursive removal a tip is printed suggesting
    the user clean up any newly orphaned packages.

    Args:
        packages: Ordered list of package names to remove
        backend: Initialised :class:`~bridge.backend.BackendCaller` instance
        recursive: When ``True`` also remove packages that depend solely
                   on the removed packages (passes ``-Rs`` to pacman)
        debug: Emit extra debug lines to the console when ``True``

    Returns:
        ``(successful, failed)`` — two lists of package names partitioned
        by whether removal succeeded or failed
    """
    success: List[str] = []
    failed: List[str] = []
    total = len(packages)

    progress = Progress(
        SpinnerColumn(),
        TextColumn("[bold blue]{task.description}"),
        BarColumn(complete_style="green", finished_style="bold green"),
        TextColumn("[progress.percentage]{task.percentage:>3.0f}%"),
        TextColumn("•"),
        TextColumn("{task.completed}/{task.total}"),
        TimeElapsedColumn(),
        console=console,
    )

    console.print()

    with progress:
        task = progress.add_task("[cyan]Removing packages...", total=total)

        for idx, pkg in enumerate(packages, 1):
            progress.update(
                task,
                description=f"[cyan]Removing {pkg}...",
                completed=idx - 1,
            )

            try:
                if debug:
                    console.print(f"[dim]DEBUG: Removing {pkg}...[/dim]")

                response = backend.remove_packages([pkg], no_confirm=True, recursive=recursive)

                if response.is_success():
                    # Double-check: pacman -Q should fail if the package was removed
                    check = subprocess.run(
                        ["pacman", "-Q", pkg],
                        capture_output=True,
                        timeout=5,
                    )
                    if check.returncode != 0:
                        success.append(pkg)
                        console.print(f"  {Icons.SUCCESS} [green]{pkg}[/green] - Removed")
                    else:
                        failed.append(pkg)
                        console.print(
                            f"  {Icons.WARNING} [yellow]{pkg}[/yellow]"
                            " - Removal reported success but package still installed"
                        )
                else:
                    failed.append(pkg)
                    error_msg = getattr(response, "message", None) or "Unknown error"
                    console.print(f"  {Icons.ERROR} [red]{pkg}[/red] - Failed: {error_msg}")

            except Exception as exc:  # noqa: BLE001
                failed.append(pkg)
                logger.debug("Exception while removing %s", pkg, exc_info=True)
                console.print(f"  {Icons.ERROR} [red]{pkg}[/red] - Error: {exc}")

            progress.update(task, completed=idx)

    # Hint: suggest orphan cleanup after non-recursive removals
    if success and not recursive:
        console.print()
        console.print("[yellow]Tip:[/yellow] You may have orphaned packages left behind.")
        console.print("Run 'Remove orphans' from the main menu to clean them up.")
        console.print()

    return success, failed


# =============================================================================
# Installation / Removal Summary Panel
# =============================================================================


def display_installation_summary(
    packages: List[str],
    package_info: Optional[dict[str, dict[str, str]]] = None,
    operation: str = "install",
    fetch_info: bool = True,
    ask_recursive: bool = False,
) -> tuple[bool, bool]:
    """
    Display a pre-operation summary panel and ask the user to confirm.

    Optionally fetches package metadata (size, description, version,
    repository) from the backend to enrich the summary.  Calculates and
    displays an approximate total installed size when size data is
    available.

    For removal operations, when ``ask_recursive=True`` the user is also
    asked whether dependencies should be removed alongside the main
    packages.

    Args:
        packages: List of package names about to be installed / removed
        package_info: Pre-fetched metadata dict keyed by package name.
                      If ``None`` and ``fetch_info=True``, metadata is
                      fetched automatically from the backend.
        operation: ``"install"`` or ``"remove"`` (affects panel title and
                   confirmation wording)
        fetch_info: Fetch package metadata from the backend when
                    ``package_info`` is ``None`` (default: ``True``)
        ask_recursive: Ask whether to also remove dependencies
                       (only meaningful when ``operation="remove"``)

    Returns:
        ``(confirmed, remove_deps)`` where *confirmed* is ``True`` if the
        user chose to proceed and *remove_deps* is ``True`` if the user
        requested recursive dependency removal.

    Note:
        Returns ``(False, False)`` immediately when *packages* is empty.
    """
    # Avoid a circular import — BackendCaller lives in bridge, not ui
    from ui.prompts import prompt_confirm

    if not packages:
        return (False, False)

    # ------------------------------------------------------------------
    # Fetch package info when not provided
    # ------------------------------------------------------------------
    if package_info is None and fetch_info:
        from bridge.backend import BackendCaller

        _backend = BackendCaller()
        package_info = {}

        with console.status("[cyan]Fetching package information...", spinner="dots"):
            for pkg in packages:
                try:
                    response = _backend.get_package_info(pkg, timeout=5)
                    if response.is_success() and response.data:
                        d = response.data
                        package_info[pkg] = {
                            "description": d.get("description", ""),
                            "size": d.get("installed_size", "Unknown"),
                            "version": d.get("version", ""),
                            "repository": d.get("repository", ""),
                        }
                    else:
                        package_info[pkg] = {
                            "description": "Package information not available",
                            "size": "Unknown",
                        }
                except Exception:  # noqa: BLE001
                    logger.warning("Failed to fetch info for package '%s'", pkg, exc_info=True)
                    package_info[pkg] = {
                        "description": "Package information not available",
                        "size": "Unknown",
                    }

    # ------------------------------------------------------------------
    # Build summary lines
    # ------------------------------------------------------------------
    title = "📦 Installation Summary" if operation == "install" else "🗑️  Removal Summary"

    total_size_kb = 0.0
    lines: List[str] = [f"[bold cyan]Packages to {operation}: {len(packages)}[/bold cyan]"]

    for pkg in packages:
        info = (package_info or {}).get(pkg, {})
        size_str = info.get("size", "Unknown")

        # Parse size string into a KB float for the total
        size_display = size_str
        try:
            size_clean = size_str.replace(",", "").strip()
            if "GiB" in size_clean or "GB" in size_clean:
                val = float(size_clean.split()[0])
                total_size_kb += val * 1024 * 1024
                size_display = f"{val:.2f} GB"
            elif "MiB" in size_clean or "MB" in size_clean:
                val = float(size_clean.split()[0])
                total_size_kb += val * 1024
                size_display = f"{val:.1f} MB"
            elif "KiB" in size_clean or "KB" in size_clean:
                val = float(size_clean.split()[0])
                total_size_kb += val
                size_display = f"{val:.0f} KB"
        except (ValueError, IndexError):
            pass  # keep size_display as the raw string

        lines.append(f"  • [cyan]{pkg}[/cyan] ({size_display})")

    # Total size row
    if total_size_kb > 0:
        lines.append("")
        if total_size_kb >= 1024 * 1024:
            total_display = f"{total_size_kb / (1024 * 1024):.2f} GB"
        elif total_size_kb >= 1024:
            total_display = f"{total_size_kb / 1024:.1f} MB"
        else:
            total_display = f"{total_size_kb:.0f} KB"
        lines.append(f"[bold yellow]Total installed size: ~{total_display}[/bold yellow]")

    console.print()
    console.print(
        Panel(
            "\n".join(lines),
            title=title,
            border_style=Colors.INFO,
            padding=(1, 2),
        )
    )
    console.print()

    # ------------------------------------------------------------------
    # Optional: ask about recursive dependency removal
    # ------------------------------------------------------------------
    remove_deps = False
    if ask_recursive and operation == "remove":
        console.print(
            f"[yellow]{Icons.WARNING}  Important:[/yellow] Removing these packages may "
            "leave dependencies orphaned."
        )
        console.print()
        console.print(
            "Examples: [dim]vlc[/dim] has 30+ dependencies like "
            "[dim]vlc-cli, vlc-gui-qt, libvlc,[/dim] etc."
        )
        console.print()
        console.print("[bold]Options:[/bold]")
        console.print("  • [cyan]Remove with dependencies[/cyan] - Clean removal (recommended)")
        console.print(
            "  • [cyan]Remove only packages[/cyan] - Keep dependencies (may leave orphans)"
        )
        console.print()
        remove_deps = prompt_confirm("Remove dependencies too?", default=True)
        console.print()

    # ------------------------------------------------------------------
    # Final confirmation
    # ------------------------------------------------------------------
    action_label = "installation" if operation == "install" else "removal"
    confirmed = prompt_confirm(f"Proceed with {action_label}?", default=True)

    return (confirmed, remove_deps)
