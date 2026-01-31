# Migration Notes

## ⚠️ Important Information

### pkgman.zsh.backup

The file `pkgman.zsh.backup` contains the original monolithic implementation.
It is kept as reference during the refactoring process.

**Status**: DEPRECATED - Do not use directly!

**Purpose**: 
- Reference for extracting functions to modules
- Backup in case of issues during migration
- Code comparison during development

**Will be removed**: After all functions are extracted to modules

### Current State

The new modular version is located in:
- **Entry point**: `bin/pkgman`
- **Modules**: `lib/*/`

### Usage

**New (Recommended)**:
```bash
./bin/pkgman
```

**Old (Deprecated)**:
```bash
./pkgman.zsh.backup  # DO NOT USE
```

### Migration Progress

See `docs/REFACTORING_PLAN.md` for detailed progress.

**Phase 1**: ✅ Complete (Core modules)
- Core modules created
- Directory structure organized
- Entry point implemented

**Phase 2-7**: 🔄 In Progress
- Extracting remaining functions from pkgman.zsh.backup
- Testing each module
- Updating documentation

## For Developers

If you need to add a feature:

1. Create module in appropriate `lib/` directory
2. Follow module template in `lib/README.md`
3. Add loading to `bin/pkgman`
4. Test thoroughly
5. Update documentation

Do NOT modify `pkgman.zsh.backup`!

## Questions?

See documentation in `docs/` directory:
- `REFACTORING_PLAN.md` - Detailed plan
- `REFACTORING_SUMMARY.md` - Summary of changes
- `PROJECT_STRUCTURE.md` - Directory structure

---

Last updated: 2026-01-31
