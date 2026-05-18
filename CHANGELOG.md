# Changelog

All notable changes to this project will be documented in this file.

## [v1.10.0] – 2026-05-18

### Fixed
- **Keybinding conflict**: `SUPER+CTRL+R` is now used by Omarchy's reminder feature since a recent Omarchy update. The Window Restore settings keybinding has been moved to `SUPER+SHIFT+ALT+R` to resolve the conflict.

### Changed
- Settings keybinding: `SUPER+CTRL+R` → `SUPER+SHIFT+ALT+R`
- Updated all references in README, install scripts, wiki and issue templates

### Upgrade notes
If you installed a previous version, re-run the installer to update your keybindings:
```bash
omarchy-install-window-restore
```
Or manually update `~/.config/hypr/bindings.conf`:
```
# Change this line:
bindd = SUPER CTRL, R, Window Restore settings, ...
# To:
bindd = SUPER SHIFT ALT, R, Window Restore settings, ...
```

---

## [v1.9.0] – 2026-04-23

### Added
- **Built-in Bug Reporter** (`SUPER+SHIFT+ALT+R` → 🐛 Create bug report): generates a privacy-safe report file in `~/Downloads/` with package/system versions, config, and window class names (no URLs or personal data)
- **Compact Settings Menu**: 7-item flat list replaced with a 3-item main menu (Mode / ⚙ Settings / 🐛 Bug report) plus a Settings sub-menu
- **ESC Navigation**: ESC in sub-menu goes back one level; ESC in main menu closes

### Fixed
- Hyprland version regex now handles `v`-prefix (e.g. `v0.48.1`)
- `.gitignore` added to exclude Python `__pycache__`

---

## [v1.8.0] – 2026-04-10

### Fixed
- **AppImage restore** (`Path /tmp/.mount_... does not exist`): AppImages mount to a temporary path at runtime. The fix reads the real path from the `$APPIMAGE` environment variable via `/proc/{pid}/environ` instead of using the mount point

---

## [v1.7.0] – 2026-04-01

### Added
- **Hide mode**: `SUPER+W` moves window to invisible workspace (process stays alive, YouTube keeps playing). `SUPER+R` brings it back instantly with full state
- **Configurable hide workspace**: change the workspace number via Settings (default: 99)
- **`SUPER+ALT+W`**: close window permanently without saving to history (original killactive behavior)
- **Media pause on close**: optionally pause media players when a window is closed or hidden
- **Notifications toggle**: enable/disable desktop notifications via Settings
- **All keybindings visible in `SUPER+K`**: all bindings use `bindd` with descriptions

---

## [v1.6.0] – 2026-03-15

### Added
- **Exclusion list**: exclude specific apps from history (added/removed via Settings menu)
- **``SUPER+ALT+P` | Picker menu: walker dmenu to choose which window to restore
- **`SUPER+CTRL+R`** settings menu (replaced by `SUPER+SHIFT+ALT+R` in v1.10.0)
- btop excluded by default (`org.omarchy.btop`)

---

## [v1.0.0] – 2026-02-01

### Initial release
- `SUPER+W`: close window and save to history
- `SUPER+R`: restore last closed window
- `SUPER+SHIFT+R`: restore all closed windows
- Relaunch mode: saves launch command, relaunches app on restore
- Browser and PWA detection (Chromium-based)
- AUR package (`omarchy-window-restore-git`)
