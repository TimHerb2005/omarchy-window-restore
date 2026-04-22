# Maintainer: Tim Herb <https://github.com/TimHerb2005>
pkgname=omarchy-window-restore
pkgver=r1
pkgrel=1
pkgdesc="Window restore feature for Omarchy — save and restore closed windows via keybindings"
arch=('any')
url="https://github.com/TimHerb2005/omarchy-window-restore"
license=('LicenseRef-PolyForm-Noncommercial-1.0.0')
depends=('python' 'hyprland' 'walker-bin')
source=("git+https://github.com/TimHerb2005/omarchy-window-restore.git")
sha256sums=('SKIP')

pkgver() {
  cd "$pkgname"
  printf "r%s.%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short HEAD)"
}

package() {
  cd "$pkgname"

  # Install scripts to shared data directory
  install -dm755 "$pkgdir/usr/share/$pkgname/bin"
  for script in bin/*; do
    install -m755 "$script" "$pkgdir/usr/share/$pkgname/$script"
  done

  # Install the user-facing setup command into PATH
  install -dm755 "$pkgdir/usr/bin"
  install -m755 /dev/stdin "$pkgdir/usr/bin/omarchy-install-window-restore" << 'EOF'
#!/bin/bash
# omarchy-install-window-restore
# Activates Window Restore for the current user.
# Run this after: yay -S omarchy-window-restore

set -e

SRC="/usr/share/omarchy-window-restore/bin"
BIN_DIR="$HOME/.local/bin"
BINDINGS_FILE="$HOME/.config/hypr/bindings.conf"
CONFIG_FILE="$HOME/.cache/hypr-restore-config.json"
MARKER="# Window Restore"

echo "Activating Omarchy Window Restore..."

# Copy scripts to user bin
mkdir -p "$BIN_DIR"
for script in "$SRC"/*; do
  install -m755 "$script" "$BIN_DIR/$(basename "$script")"
done
echo "  ✓ Scripts installed to $BIN_DIR"

# Add keybindings (idempotent)
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

# Create default config with org.omarchy.btop excluded
if [ ! -f "$CONFIG_FILE" ]; then
  mkdir -p "$(dirname "$CONFIG_FILE")"
  echo '{"max_windows": 5, "excluded_classes": ["org.omarchy.btop"]}' > "$CONFIG_FILE"
  echo "  ✓ Default config created"
fi

echo ""
echo "Done! Keybindings are active immediately."
echo ""
echo "  SUPER+W           → Close window (saved to history)"
echo "  SUPER+R           → Restore last closed window"
echo "  SUPER+SHIFT+R     → Restore all closed windows"
echo "  SUPER+ALT+R       → Pick window to restore (menu)"
echo "  SUPER+CTRL+R      → Settings (mode, max windows, exclusions)"
EOF
}
