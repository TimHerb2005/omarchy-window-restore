---
name: Bug report
about: Something isn't working as expected
labels: bug
---

**Describe the bug**
A clear description of what the problem is.

**To reproduce**
Steps to reproduce the behavior.

**Expected behavior**
What you expected to happen.

**Environment**

> 💡 Tip: Press `SUPER+CTRL+R` → **🐛 Create bug report** to auto-generate a report file with all system info.
> Attach the generated file from `~/Downloads/` to this issue.

If you prefer to fill in manually:
- Omarchy version: (run `omarchy-version`)
- Hyprland version: (run `hyprctl version`)
- Package version: (run `pacman -Q omarchy-window-restore-git`)
- Mode: Relaunch / Hide
- App(s) affected:

**Logs / output**
Run the affected script manually and paste the output:
```bash
python3 ~/.local/bin/hypr-close-window
# or
python3 ~/.local/bin/hypr-restore-window
```
