#!/bin/bash
# uninstall.sh – removes Omarchy Window Restore

set -e

BIN_DIR="$HOME/.local/bin"
BINDINGS_FILE="$HOME/.config/hypr/bindings.conf"

echo "Uninstalling Omarchy Window Restore..."

# Remove scripts
for script in hypr-close-window hypr-restore-window hypr-restore-all hypr-restore-picker; do
  rm -f "$BIN_DIR/$script"
done
echo "  ✓ Scripts removed"

# Remove keybindings block (everything between marker and next blank line after block)
if grep -q "# Window Restore" "$BINDINGS_FILE" 2>/dev/null; then
  # Remove the block including the unbind and 4 bind lines
  python3 - "$BINDINGS_FILE" << 'EOF'
import sys

path = sys.argv[1]
with open(path) as f:
    lines = f.readlines()

out = []
skip = False
i = 0
while i < len(lines):
    line = lines[i]
    if "# Window Restore" in line:
        skip = True
    if skip and line.strip() == "" and i > 0 and "# Window Restore" not in lines[i-1]:
        skip = False
    if not skip:
        out.append(line)
    i += 1

with open(path, "w") as f:
    f.writelines(out)
EOF
  echo "  ✓ Keybindings removed"
  echo "  ℹ  SUPER+W is restored to default (killactive) behavior"
fi

# Clean up history cache
rm -f "$HOME/.cache/hypr-window-history.json"
echo "  ✓ History cleared"

echo ""
echo "Uninstall complete."
