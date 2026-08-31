# Changelog

All notable changes to this project will be documented in this file.

## [v1.13.0] – 2026-08-31

### Fixed
- **Git-clone install/uninstall on Quattro**: `install.sh` and `uninstall.sh` (the manual git-clone path) never got the Lua-detection fix from v1.12.0 — they still unconditionally wrote/removed the keybinding block in `~/.config/hypr/bindings.conf`, which Hyprland no longer reads once `hyprland.lua` exists. Only `omarchy-install-window-restore`/`omarchy-uninstall-window-restore` (the AUR path) had been updated. Both scripts now use the same Lua-detection and dual-file removal logic, so git-clone installs work on Quattro too.
- **Wiki out of date**: Code-Documentation and Troubleshooting pages still described the old `hyprctl dispatch killactive`/`movetoworkspacesilent` calls and only referenced `bindings.conf`, both wrong since v1.12.0. Updated to reflect the `hl.dsp.window.*` dispatch syntax and the Lua/`.conf` split.

## [v1.12.0] – 2026-08-26

### Fixed
- **Broken on Omarchy "Quattro" (Hyprland 0.56+)**: Hyprland 0.56 moved `hyprctl dispatch` to a Lua-only calling convention — the classic `hyprctl dispatch closewindow address:...` / `killactive` / `movetoworkspace ...` / `movetoworkspacesilent ...` syntax now fails with `hl.dispatch: expected a dispatcher`. Every dispatch call in `hypr-close-window`, `hypr-restore-window`, `hypr-restore-all`, and `hypr-restore-settings` now uses the new `hl.dsp.window.close({ window = "address:..." })` / `hl.dsp.window.move({ workspace = ..., window = "address:...", follow = ... })` syntax. This is what broke SUPER+W, SUPER+ALT+W, and window restore entirely after updating to Quattro.
- **Keybinding install on Quattro**: Omarchy "Quattro" also switched Hyprland's own config from `~/.config/hypr/bindings.conf` to native Lua (`~/.config/hypr/bindings.lua`), which Hyprland now loads instead of the `.conf` files once it exists. `omarchy-install-window-restore` / `omarchy-uninstall-window-restore` now detect which config style is active (presence of `~/.config/hypr/hyprland.lua`) and write/remove the keybinding block in the right file and syntax, instead of silently landing in a `.conf` file Hyprland no longer reads.

### Requires
- Hyprland 0.56+ (Omarchy "Quattro" or newer) for the dispatch fix above. Older Omarchy/Hyprland versions should stay on v1.11.0.

## [v1.11.0] – 2026-05-18

### Fixed
- **Walker dmenu items not showing**: Walker 2.x runs as a GApplication daemon and does not receive stdin from Python's `subprocess.run(input=...)`. All walker dmenu calls now use a shell pipe with `omarchy-launch-walker` — the same approach used by Omarchy's own menu scripts. This caused every menu (settings and picker) to show only an empty search field.
- **Settings keybinding**: Finalized to `SUPER+D` — all previous attempts (`SUPER+CTRL+R`, `SUPER+SHIFT+ALT+R`, `SUPER+CTRL+D`) caused conflicts with Omarchy keybindings or Hyprland modifier subset-matching behaviour.

### Changed
- `hypr-restore-settings`: `pick()` and `input_text()` now use shell pipe with `omarchy-launch-walker`
- `hypr-restore-picker`: `show_picker()` now uses shell pipe with `omarchy-launch-walker`
- Settings keybinding settled on `SUPER+D`
- Picker keybinding stays on `SUPER+ALT+R`

### Upgrade notes
Re-run the installer to update keybindings and scripts:
```bash
omarchy-install-window-restore
```

---

## [v1.10.0] – 2026-05-18

### Fixed
- **Keybinding conflict**: `SUPER+CTRL+R` is now used by Omarchy's reminder feature since a recent Omarchy update. The Window Restore settings keybinding has been moved to `SUPER+D` to resolve the conflict.

### Changed
- Settings keybinding: `SUPER+CTRL+R` → `SUPER+D`
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
bindd = SUPER, D, Window Restore settings, ...
```

---

## [v1.9.0] – 2026-04-23

### Added
- **Built-in Bug Reporter** (`SUPER+D` → 🐛 Create bug report): generates a privacy-safe report file in `~/Downloads/` with package/system versions, config, and window class names (no URLs or personal data)
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
- **``SUPER+ALT+R` | Picker menu: walker dmenu to choose which window to restore
- **`SUPER+CTRL+R`** settings menu (replaced by `SUPER+D` in v1.10.0)
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
