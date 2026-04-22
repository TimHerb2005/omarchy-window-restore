#!/bin/bash
# install.sh – Installs Omarchy Window Restore from the cloned repo.
# After installing, use SUPER+W to close windows (saved to history)
# and SUPER+R to restore the last closed window.

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$HOME/.local/bin"
BINDINGS_FILE="$HOME/.config/hypr/bindings.conf"
CONFIG_FILE="$HOME/.cache/hypr-restore-config.json"
MARKER="# Window Restore"

echo "Installing Omarchy Window Restore..."

# Install scripts
mkdir -p "$BIN_DIR"
for script in hypr-close-window hypr-restore-window hypr-restore-all hypr-restore-picker hypr-restore-settings; do
  install -m 755 "$REPO_DIR/bin/$script" "$BIN_DIR/$script"
done

echo "  ✓ Scripts installed to $BIN_DIR"

# Add keybindings (idempotent – skip if already present)
if grep -q "$MARKER" "$BINDINGS_FILE" 2>/dev/null; then
  echo "  ✓ Keybindings already present, skipping"
else
  cat >> "$BINDINGS_FILE" << 'BINDINGS'

# Window Restore: SUPER+W saves to history and closes, SUPER+R restores last window
unbind = SUPER, W
bindd = SUPER, W, Close window (restorable via SUPER+R), exec, python3 ~/.local/bin/hypr-close-window
bindd = SUPER, R, Restore last closed window, exec, python3 ~/.local/bin/hypr-restore-window
bindd = SUPER SHIFT, R, Restore all closed windows, exec, python3 ~/.local/bin/hypr-restore-all
bindd = SUPER ALT, R, Pick window to restore (menu), exec, python3 ~/.local/bin/hypr-restore-picker
bindd = SUPER CTRL, R, Window Restore settings, exec, python3 ~/.local/bin/hypr-restore-settings
BINDINGS
  echo "  ✓ Keybindings added to $BINDINGS_FILE"
fi

# Create default config (idempotent – skip if already present)
if [ ! -f "$CONFIG_FILE" ]; then
  mkdir -p "$(dirname "$CONFIG_FILE")"
  echo '{"max_windows": 5, "excluded_classes": ["org.omarchy.btop"], "pause_on_close": true, "notifications_enabled": true}' > "$CONFIG_FILE"
  echo "  ✓ Default config created (btop excluded by default)"
fi

echo ""
echo "Done! Keybindings are active immediately."
echo ""
echo "  SUPER+W           → Close window (saved to history)"
echo "  SUPER+R           → Restore last closed window"
echo "  SUPER+SHIFT+R     → Restore all closed windows"
echo "  SUPER+ALT+R       → Pick window to restore (menu)"
echo "  SUPER+CTRL+R      → Settings (mode, max windows, exclusions, pause, notifications)"
