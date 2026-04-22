# Omarchy Window Restore

> Never lose a closed window again on [Omarchy](https://omarchy.org/).

Replaces `SUPER+W` with a smarter close that saves windows to a history stack — so you can restore them with `SUPER+R`.

Works for **all apps**: browser windows, PWAs (Teams, ChatGPT, etc.), terminals, editors, and more.

<video src="demo.mp4" controls autoplay loop muted width="100%"></video>

## Keybindings

| Shortcut | Action |
|---|---|
| `SUPER+W` | Close window *(saved to history)* |
| `SUPER+R` | Restore the last closed window |
| `SUPER+SHIFT+R` | Restore **all** closed windows at once |
| `SUPER+ALT+R` | Open a **picker menu** to choose which window to restore |
| `SUPER+CTRL+R` | Open **Settings** (mode, max windows, exclusions) |

## Restore Modes

Switch between modes anytime via `SUPER+CTRL+R → Mode → switch`.

### Relaunch Mode *(default)*
`SUPER+W` kills the window and saves the launch command. `SUPER+R` restarts the app fresh.

- ✅ Low memory usage (process is gone)
- ❌ App content is lost (browser tabs, unsaved state)
- 💡 Browsers can recover tabs via built-in session restore

### Hide Mode
`SUPER+W` moves the window to an invisible workspace. The process keeps running. `SUPER+R` brings it back exactly as it was.

- ✅ Full state preserved — YouTube keeps playing, tabs stay open
- ✅ Instant restore (no relaunch delay)
- ❌ Uses more RAM (process stays alive)

> **Note:** Switching from Hide → Relaunch mode will close all currently hidden windows.

## Settings Menu (`SUPER+CTRL+R`)

| Option | Description |
|---|---|
| **Mode** | Toggle between Relaunch and Hide mode |
| **Max windows** | Set how many windows are kept in history (default: 5, min: 1) |
| **Exclusion list** | Exclude specific apps from history (e.g. terminals) |

### Exclusion List

Apps on the exclusion list are closed normally but **not saved to history**. Useful for apps you never want to restore.

`org.omarchy.btop` (the system monitor) is excluded by default.

To add an app, open `SUPER+CTRL+R → Exclusion list` and either:
- **Pick from open windows** — select any currently open app
- **Enter app ID manually** — type the window class directly

#### How to find the window class of an app

Run either of these commands:

```bash
# Class of the currently focused window
hyprctl activewindow -j | jq '.class'

# Classes of all open windows
hyprctl clients -j | jq -r '.[].class'
```

Common examples:

| App | Window class |
|---|---|
| Chromium | `chromium` |
| VS Code | `code` |
| Alacritty | `Alacritty` |
| Spotify | `spotify` |
| btop (Omarchy) | `org.omarchy.btop` |
| Teams (PWA) | `chrome-teams.cloud.microsoft__-Default` |

## How it works

When you press `SUPER+W`:
1. The window class is checked against the exclusion list
2. If not excluded, the window is saved to history
3. In **Relaunch** mode: window is killed, launch command stored
4. In **Hide** mode: window is moved silently to workspace 99 (invisible, process stays alive)

For Chromium-based apps, the window **class** is used to identify the correct launch command (not the PID, since all Chromium windows share one process):
- `class = chromium` → `omarchy-launch-browser`
- `class = chrome-teams.cloud.microsoft__-Default` → `omarchy-launch-webapp https://teams.cloud.microsoft/`

> **Note (Relaunch mode):** App *content* (e.g. browser tabs) is not preserved — the app simply relaunches. For browsers, built-in session restore will recover tabs.

## Requirements

- [Omarchy](https://omarchy.org/) (Hyprland-based)
- Python 3.10+
- `walker` (included with Omarchy, used for picker and settings menus)

## Install

### Option 1: Git clone (manual)

```bash
git clone https://github.com/TimHerb2005/omarchy-window-restore.git
cd omarchy-window-restore
bash install.sh
```

### Option 2: AUR package

Install via any AUR helper:

```bash
yay -S omarchy-window-restore-git
```

Then activate for your user:

```bash
omarchy-install-window-restore
```

Or via the **Omarchy Menu**: `Install → AUR` → type `omarchy-window-restore-git`, then run `omarchy-install-window-restore` in a terminal afterwards.

---

Both options:
- Copy scripts to `~/.local/bin/`
- Add keybindings to `~/.config/hypr/bindings.conf`
- Hyprland reloads the config automatically — **no restart needed**

## Uninstall

```bash
bash uninstall.sh
```

Removes all scripts, keybindings and the history cache. `SUPER+W` returns to its default behavior.

## Files

```
~/.local/bin/
├── hypr-close-window           # SUPER+W: save to history/hide, then close
├── hypr-restore-window         # SUPER+R: restore last window
├── hypr-restore-all            # SUPER+SHIFT+R: restore all windows
├── hypr-restore-picker         # SUPER+ALT+R: walker picker menu
└── hypr-restore-settings       # SUPER+CTRL+R: settings menu

~/.cache/
├── hypr-window-history.json    # Relaunch mode history (max N entries)
├── hypr-restore-hidden.json    # Hide mode address list (max N entries)
├── hypr-restore-mode           # Current mode: "relaunch" or "hide"
└── hypr-restore-config.json    # Settings: max_windows, excluded_classes
```

## License

[PolyForm Noncommercial License 1.0.0](LICENSE) — free for personal and non-commercial use, commercial use is not permitted.

