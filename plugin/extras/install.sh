#!/bin/bash
# plugin/extras/install.sh — installs the Window Restore Quickshell plugin
# (native settings + picker overlays, replacing the omarchy-menu-select/
# omarchy-menu-input-driven menus) and points SUPER+D / SUPER+ALT+R at it.
#
# Requires the base tool already installed (bash install.sh, or
# omarchy-install-window-restore for the AUR package) and Omarchy "Quattro"
# (Hyprland 0.56+, native Lua config) — the plugin system this depends on
# does not exist on older Omarchy.

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PLUGIN_SRC="$REPO_DIR/plugin"
PLUGIN_ID="io.github.timherb2005.window-restore"
PLUGIN_DIR="$HOME/.config/omarchy/plugins/$PLUGIN_ID"
BINDINGS_FILE="$HOME/.config/hypr/bindings.lua"
CLI="$HOME/.local/bin/hypr-restore-settings"
PICKER="$HOME/.local/bin/hypr-restore-picker"
MENU_FILE="$HOME/.config/omarchy/extensions/omarchy-menu.jsonc"

if [ ! -f "$HOME/.config/hypr/hyprland.lua" ]; then
  echo "This plugin needs Omarchy \"Quattro\" (Hyprland 0.56+ native Lua config)." >&2
  exit 1
fi

if [ ! -x "$CLI" ] || [ ! -x "$PICKER" ]; then
  echo "Install the base tool first: bash install.sh (or omarchy-install-window-restore for the AUR package)." >&2
  exit 1
fi

echo "Installing Window Restore Quickshell plugin..."

mkdir -p "$(dirname "$PLUGIN_DIR")"
rm -rf "$PLUGIN_DIR"
cp -r "$PLUGIN_SRC" "$PLUGIN_DIR"
echo "  ✓ Plugin copied to $PLUGIN_DIR"

omarchy plugin enable "$PLUGIN_ID" >/dev/null 2>&1 || true
omarchy-shell shell rescanPlugins >/dev/null 2>&1 || true
echo "  ✓ Plugin enabled"

# Point SUPER+D / SUPER+ALT+R at the plugin instead of the Python-driven
# omarchy-menu-select/omarchy-menu-input menus (idempotent: only rewrites the
# lines if they still call the Python scripts directly).
python3 - "$BINDINGS_FILE" "$PLUGIN_ID" << 'PYEOF'
import sys

path, plugin_id = sys.argv[1], sys.argv[2]
with open(path) as f:
    text = f.read()

settings_old = 'o.bind("SUPER + D", "Window Restore settings", "python3 ~/.local/bin/hypr-restore-settings")'
picker_old = 'o.bind("SUPER + ALT + R", "Pick window to restore (menu)", "python3 ~/.local/bin/hypr-restore-picker")'
settings_new = (
    'o.bind("SUPER + D", "Window Restore settings", '
    '"omarchy-shell shell summon %s \'{\\"view\\":\\"settings\\"}\'")' % plugin_id
)
picker_new = (
    'o.bind("SUPER + ALT + R", "Pick window to restore (menu)", '
    '"omarchy-shell shell summon %s \'{\\"view\\":\\"picker\\"}\'")' % plugin_id
)

changed = False
if settings_old in text:
    text = text.replace(settings_old, settings_new)
    changed = True
if picker_old in text:
    text = text.replace(picker_old, picker_new)
    changed = True

if changed:
    with open(path, "w") as f:
        f.write(text)
    print("  ✓ SUPER+D and SUPER+ALT+R now open the native plugin menus")
else:
    print("  ✓ SUPER+D and SUPER+ALT+R already point at the plugin (or a custom binding) — left as is")
PYEOF

# Add "Window Restore" to the Omarchy menu too (Settings / Picker). Done in
# Python (not sed/awk -v) because the entries contain literal backslash-quote
# sequences (the JSON payload embedded in each action's shell command) that
# awk's -v assignment would silently unescape.
if [ -f "$MENU_FILE" ] && command grep -q '"window-restore"' "$MENU_FILE" 2>/dev/null; then
  echo "  ✓ Omarchy menu entry already present"
else
  mkdir -p "$(dirname "$MENU_FILE")"
  [ -f "$MENU_FILE" ] || printf '{\n}\n' > "$MENU_FILE"
  python3 - "$MENU_FILE" "$PLUGIN_SRC/extras/omarchy-menu.jsonc" << 'PYEOF'
import sys

target_path, source_path = sys.argv[1], sys.argv[2]

with open(source_path) as f:
    entry_lines = [l.rstrip("\n") for l in f if l.startswith('  "')]

with open(target_path) as f:
    lines = f.readlines()

last = len(lines) - 1
while last >= 0 and "}" not in lines[last]:
    last -= 1

prev = last - 1
while prev >= 0 and (lines[prev].strip() == "" or lines[prev].strip().startswith("//")):
    prev -= 1

if prev >= 0 and not lines[prev].rstrip("\n").rstrip().endswith(("{", ",")):
    lines[prev] = lines[prev].rstrip("\n") + ",\n"

insert = [line + "\n" for line in entry_lines]
lines[last:last] = insert

with open(target_path, "w") as f:
    f.writelines(lines)
PYEOF
  echo "  ✓ Added Window Restore to the Omarchy menu"
fi

echo ""
echo "Done. Hyprland reloads bindings.lua automatically — no restart needed."
echo "If SUPER+D / SUPER+ALT+R don't pick it up right away, run: omarchy restart shell"
