#!/bin/bash
# omarchy-install-window-restore
# Installs the Omarchy Window Restore feature.
# After installing, use SUPER+W to close windows (saved to history)
# and SUPER+R to restore the last closed window.

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$HOME/.local/bin"
BINDINGS_FILE="$HOME/.config/hypr/bindings.conf"
MARKER="# Window Restore"

echo "Installing Omarchy Window Restore..."

# Install scripts
mkdir -p "$BIN_DIR"
for script in hypr-close-window hypr-restore-window hypr-restore-all hypr-restore-picker; do
  install -m 755 "$REPO_DIR/bin/$script" "$BIN_DIR/$script"
done

echo "  ✓ Scripts installed to $BIN_DIR"

# Add keybindings (idempotent – skip if already present)
if grep -q "$MARKER" "$BINDINGS_FILE" 2>/dev/null; then
  echo "  ✓ Keybindings already present, skipping"
else
  cat >> "$BINDINGS_FILE" << 'BINDINGS'

# Window Restore: SUPER+W speichert in History und schließt, SUPER+R öffnet letztes wieder (max. 5)
unbind = SUPER, W
bindd = SUPER, W, Close window (restorable via SUPER+R), exec, python3 ~/.local/bin/hypr-close-window
bindd = SUPER, R, Restore last closed window, exec, python3 ~/.local/bin/hypr-restore-window
bindd = SUPER SHIFT, R, Restore all closed windows, exec, python3 ~/.local/bin/hypr-restore-all
bindd = SUPER ALT, R, Pick window to restore (menu), exec, python3 ~/.local/bin/hypr-restore-picker
BINDINGS
  echo "  ✓ Keybindings added to $BINDINGS_FILE"
fi

echo ""
echo "Done! Keybindings are active immediately."
echo ""
echo "  SUPER+W           → Close window (saved to history)"
echo "  SUPER+R           → Restore last closed window"
echo "  SUPER+SHIFT+R     → Restore all closed windows"
echo "  SUPER+ALT+R       → Pick window to restore (menu)"
