# Contributing

Thanks for your interest! Here's how to contribute.

## Reporting bugs

Use the [bug report template](.github/ISSUE_TEMPLATE/bug_report.md). Please include your Omarchy/Hyprland version and the output of running the affected script directly in a terminal.

## Suggesting features

Use the [feature request template](.github/ISSUE_TEMPLATE/feature_request.md).

## Pull requests

1. Fork the repo and create a branch from `main`
2. Test your changes locally: `bash install.sh` then try the keybindings
3. Keep scripts compatible with Python 3.10+
4. Submit the PR with a clear description of what changed and why

## Project structure

```
bin/           Python scripts (installed to ~/.local/bin/)
hooks/         alpm hooks for pacman integration
install.sh     Manual install script
uninstall.sh   Manual uninstall script
PKGBUILD       AUR package definition
```

## License

By contributing, you agree that your contributions are licensed under the [PolyForm Noncommercial License 1.0.0](LICENSE).
