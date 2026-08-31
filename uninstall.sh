#!/bin/bash
# uninstall.sh – removes Omarchy Window Restore

set -e

BIN_DIR="$HOME/.local/bin"

echo "Uninstalling Omarchy Window Restore..."

# Remove scripts
for script in hypr-close-window hypr-restore-window hypr-restore-all hypr-restore-picker hypr-restore-settings; do
  rm -f "$BIN_DIR/$script"
done
echo "  ✓ Scripts removed"

# Remove keybindings block from whichever file has it (Lua for Omarchy
# "Quattro"/Hyprland 0.56+, classic .conf for older Omarchy versions).
remove_marker_block() {
  local file="$1" marker="$2"
  if grep -q "$marker" "$file" 2>/dev/null; then
    python3 - "$file" "$marker" << 'EOF'
import sys

path, marker = sys.argv[1], sys.argv[2]
with open(path) as f:
    lines = f.readlines()

out = []
skip = False
i = 0
while i < len(lines):
    line = lines[i]
    if marker in line:
        skip = True
    if skip and line.strip() == "" and i > 0 and marker not in lines[i-1]:
        skip = False
    if not skip:
        out.append(line)
    i += 1

with open(path, "w") as f:
    f.writelines(out)
EOF
    echo "  ✓ Keybindings removed from $file"
    return 0
  fi
  return 1
}

removed=0
if remove_marker_block "$HOME/.config/hypr/bindings.lua" "-- Window Restore"; then
  removed=1
  echo "  ℹ  SUPER+W is restored to Omarchy's default binding"
fi
if remove_marker_block "$HOME/.config/hypr/bindings.conf" "# Window Restore"; then
  removed=1
  echo "  ℹ  SUPER+W is restored to default (killactive) behavior"
fi
[ "$removed" = "1" ] || true

# Clean up all cache files
rm -f "$HOME/.cache/hypr-window-history.json"
rm -f "$HOME/.cache/hypr-window-history.log"
rm -f "$HOME/.cache/hypr-restore-hidden.json"
rm -f "$HOME/.cache/hypr-restore-mode"
rm -f "$HOME/.cache/hypr-restore-config.json"
echo "  ✓ Cache cleared"

echo ""
echo "Uninstall complete."
