# Refactoring Plan

## Status: In Progress

### Completed ✅
- [x] Create directory structure
- [x] Create core modules:
  - [x] lib/core/colors.zsh (135 lines)
  - [x] lib/core/ui.zsh (287 lines)
  - [x] lib/core/detect.zsh (324 lines)
  - [x] lib/core/utils.zsh (501 lines)
- [x] Create main entry point: bin/pkgman (194 lines)
- [x] Move documentation to docs/
- [x] Move scripts to scripts/

### Remaining Modules to Extract 📝

From pkgman.zsh (2475 lines total), extract to:

#### Package Management (`lib/package/`)
- [ ] `install.zsh` - install_package() function
- [ ] `remove.zsh` - remove_package() function
- [ ] `update.zsh` - update_system() function
- [ ] `search.zsh` - search_package() function
- [ ] `info.zsh` - package_info() function

#### System Maintenance (`lib/system/`)
- [ ] `cache.zsh` - clean_cache() function
- [ ] `orphan.zsh` - remove_orphans() function
- [ ] `broken.zsh` - check_broken() function
- [ ] `list.zsh` - list_installed() function

#### Advanced Features (`lib/advanced/`)
- [ ] `downgrade.zsh` - downgrade_package() function
- [ ] `logs.zsh` - view_logs() function
- [ ] `mirror.zsh` - mirror_management() function
- [ ] `yay.zsh` - install_yay() function

#### Font Management (`lib/font/`)
- [ ] `menu.zsh` - font_manager_menu() function
- [ ] `install.zsh` - All install_*_fonts() functions
- [ ] `manage.zsh` - list/search/remove font functions
- [ ] `test.zsh` - test_font_display() function

#### Development Tools (`lib/devtools/`)
- [ ] `menu.zsh` - dev_tools_menu() function
- [ ] `web.zsh` - install_php_stack(), install_laravel(), install_nodejs_stack()
- [ ] `database.zsh` - install_postgresql(), install_mysql(), etc.
- [ ] `language.zsh` - install_java(), install_python_stack(), etc.
- [ ] `devops.zsh` - install_docker(), install_git(), etc.

## Migration Strategy

1. Extract functions one module at a time
2. Test each module independently
3. Update bin/pkgman to load new module
4. Remove extracted code from pkgman.zsh
5. Repeat until pkgman.zsh is empty (only kept for backwards compatibility)

## Testing Checklist

After extracting each module:
- [ ] Syntax check: `zsh -n bin/pkgman`
- [ ] Function availability: Test each menu option
- [ ] No regressions: Compare with old behavior
- [ ] Documentation updated

## Final Steps

- [ ] Remove old pkgman.zsh or keep as legacy entry point
- [ ] Update install.sh to use bin/pkgman
- [ ] Update README with new structure
- [ ] Create migration guide
- [ ] Update CHANGELOG
