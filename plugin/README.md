# Window Restore (Quickshell plugin)

A native Omarchy "Quattro" shell plugin for [omarchy-window-restore](../README.md). Replaces the `omarchy-menu-select`/`omarchy-menu-input`-driven settings and picker menus with first-class Quickshell overlays that match the rest of the system's theme, and adds a "Window Restore" entry to the Omarchy menu.

All state still lives in the same `~/.cache/hypr-restore-*` files the base tool uses, and every change still goes through `hypr-restore-settings`/`hypr-restore-picker` — this plugin only draws the menu and reads/writes through those scripts, so both front ends (the plugin and the plain keybinding-only install) stay in sync automatically.

## Requirements

- The base tool already installed and activated (`bash install.sh` from the repo root, or `omarchy-install-window-restore` for the AUR package) — this plugin calls `~/.local/bin/hypr-restore-settings` and `~/.local/bin/hypr-restore-picker`, it doesn't replace them.
- Omarchy "Quattro" (Hyprland 0.56+, native Lua config and the Quickshell-based `omarchy.menu`/plugin system). There is no non-plugin fallback for older Omarchy — stay on the plain keybinding install there.

## Install

```bash
git clone https://github.com/TimHerb2005/omarchy-window-restore.git
cd omarchy-window-restore
bash install.sh              # base tool, if not already installed
bash plugin/extras/install.sh
```

This:
- Copies `plugin/` to `~/.config/omarchy/plugins/io.github.timherb2005.window-restore/` and enables it
- Repoints `SUPER+D` and `SUPER+ALT+R` in `~/.config/hypr/bindings.lua` at the plugin instead of the Python-driven menus (only if they still point at the stock scripts — a custom binding is left alone)
- Adds "Window Restore" → Settings / Restore window… to the Omarchy menu (`~/.config/omarchy/extensions/omarchy-menu.jsonc`)

If the keybindings don't pick it up immediately, run `omarchy restart shell`.

## Uninstall

```bash
omarchy plugin remove io.github.timherb2005.window-restore
```

Then either revert the two `o.bind` lines in `~/.config/hypr/bindings.lua` back to `"python3 ~/.local/bin/hypr-restore-settings"` / `"python3 ~/.local/bin/hypr-restore-picker"`, or re-run `bash install.sh` from the repo root (it only touches the binding block if the marker is missing, so edit those two lines manually first if you want it fully back to the plain CLI).

## Files

```
plugin/
├── manifest.json              # Quickshell plugin manifest (schemaVersion 1, kind: overlay)
├── WindowRestore.qml          # Settings + picker overlay UI
├── WindowRestoreModel.js      # Pure row-building helpers, no side effects
└── extras/
    ├── install.sh             # Installs the plugin, rewires keybindings, updates the Omarchy menu
    └── omarchy-menu.jsonc     # The menu entries install.sh merges in
```

## Why a separate install step

The plugin is optional on top of the base tool rather than a replacement, mainly because `omarchy-menu-select`/`omarchy-menu-input` (what the base tool uses today) still work fine and need no plugin system at all — the plugin exists for a nicer, more integrated UI, not because the CLI menus are broken. Keeping it a separate, skippable step means anyone who just wants the keybindings never needs a Quickshell plugin enabled in their long-lived shell process.
