# Omarchy Window Restore

> Never lose a closed window again on [Omarchy](https://omarchy.org/).

Replaces `SUPER+W` with a smarter close that saves windows to a history stack — so you can restore them with `SUPER+R`.

Works for **all apps**: browser windows, PWAs (Teams, ChatGPT, etc.), terminals, editors, and more.

## Keybindings

| Shortcut | Action |
|---|---|
| `SUPER+W` | Close window *(saved to history)* |
| `SUPER+R` | Restore the last closed window |
| `SUPER+SHIFT+R` | Restore **all** closed windows at once |
| `SUPER+ALT+R` | Open a **picker menu** to choose which window to restore |

Up to **5 windows** are kept in history. Once the limit is reached, the oldest entry is dropped.

## How it works

When you press `SUPER+W`:
1. The active window's identity is saved to `~/.cache/hypr-window-history.json`
2. The window is closed normally

When you press `SUPER+R`:
1. The most recently closed window is re-launched
2. For browser PWAs (Teams, ChatGPT, etc.) — the correct `--app=URL` is used
3. For regular browsers — `omarchy-launch-browser` is used
4. For all other apps — the original executable + arguments are used

> **Note:** App *content* (e.g. browser tabs) is not preserved — the app simply relaunches. For browsers, the built-in session restore will recover your tabs.

## Requirements

- [Omarchy](https://omarchy.org/) (Hyprland-based)
- Python 3.10+
- `walker` (included with Omarchy, used for the picker menu)

## Install

```bash
git clone https://github.com/TimHerb2005/omarchy-window-restore.git
cd omarchy-window-restore
bash install.sh
```

The install script:
- Copies 4 scripts to `~/.local/bin/`
- Adds keybindings to `~/.config/hypr/bindings.conf`
- Hyprland reloads the config automatically — **no restart needed**

## Uninstall

```bash
bash uninstall.sh
```

This removes all scripts, keybindings and the history cache. `SUPER+W` returns to its default behavior.

## Files

```
~/.local/bin/
├── hypr-close-window       # SUPER+W: save to history, then killactive
├── hypr-restore-window     # SUPER+R: restore last closed window
├── hypr-restore-all        # SUPER+SHIFT+R: restore all windows
└── hypr-restore-picker     # SUPER+ALT+R: walker picker menu

~/.cache/hypr-window-history.json   # Runtime history (max 5 entries)
```

## License

MIT
