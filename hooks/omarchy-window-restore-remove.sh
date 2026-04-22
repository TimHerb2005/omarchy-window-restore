#!/bin/bash
# Runs as root before omarchy-window-restore-git is removed.
# Cleans up user-level scripts, keybindings and cache for all affected users.

for user_home in /home/*/; do
    user=$(basename "$user_home")
    if [ -f "$user_home/.local/bin/hypr-close-window" ]; then
        echo "  → Removing Window Restore config for user: $user"
        runuser -l "$user" -c "omarchy-uninstall-window-restore" 2>/dev/null || true
    fi
done
