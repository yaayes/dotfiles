# dotfiles

My NixOS configuration managed with [Nix Flakes](https://nixos.wiki/wiki/Flakes) and [Home Manager](https://github.com/nix-community/home-manager).

## Overview

| Component | Choice |
|---|---|
| OS | NixOS (unstable channel) |
| Window Manager | [Hyprland](https://hyprland.org/) |
| Display Manager | [SDDM](https://github.com/sddm/sddm) + [astronaut theme](https://github.com/Keyitdev/sddm-astronaut-theme) |
| Shell | Zsh + Oh My Zsh |
| Terminal | [Kitty](https://sw.kovidgoyal.net/kitty/) / [Alacritty](https://alacritty.org/) |
| Status Bar / Shell UI | [Noctalia Shell](https://github.com/noctalia-dev/noctalia-shell) |
| App Launcher | [Rofi](https://github.com/davatorium/rofi) |
| Notifications | [Mako](https://github.com/emersion/mako) |
| File Manager | [Nautilus](https://gitlab.gnome.org/GNOME/nautilus) (GUI) · [Yazi](https://yazi-rs.github.io/) (TUI) |
| Multiplexer | [Zellij](https://zellij.dev/) |
| Browser | [Zen Browser](https://github.com/youwen5/zen-browser-flake) · Google Chrome · Firefox |
| Audio | [Pipewire](https://pipewire.org/) + [EasyEffects](https://github.com/wwmm/easyeffects) |
| Theme | [Catppuccin Mocha](https://catppuccin.com/) throughout |
| Cursor | [Bibata Modern Classic](https://github.com/ful1e5/Bibata_Cursor) |
| Fonts | JetBrains Mono Nerd Font · Font Awesome · Noto |

## Structure

```
.
├── flake.nix           # Flake inputs & outputs (entry point)
├── configuration.nix   # System-level NixOS config (hardware, services, users)
├── home.nix            # Home Manager config (user environment, symlinks)
├── packages.nix        # User packages (imported by home.nix)
└── config/             # App config files (symlinked into ~/.config/)
    ├── alacritty/
    ├── chrome/
    ├── easyeffects/
    ├── hypr/           # Hyprland, hypridle, hyprlock configs
    ├── kitty/
    ├── noctalia/       # Noctalia Shell config & plugins
    ├── rofi/
    ├── waybar/
    ├── zellij/
    └── zsh/
```

## Flake Inputs

- **nixpkgs** — `nixos-unstable`
- **home-manager** — tracks `master`
- **noctalia / noctalia-qs** — Noctalia Shell and its Quick Settings module
- **catppuccin/nix** — Catppuccin theme module for Home Manager
- **zen-browser-flake** — Zen Browser packaged for Nix
- **sddm-astronaut-theme** — SDDM login screen theme (fetched as a plain source)

## Live Config Editing

Config files under `config/` are symlinked into `~/.config/` as **out-of-store symlinks** via Home Manager. This means you can edit any file in this repo and see the changes immediately — no `nixos-rebuild switch` or `home-manager switch` required for config tweaks.

The symlinked directories are:

```
~/.config/alacritty  →  config/alacritty/
~/.config/hypr       →  config/hypr/
~/.config/kitty      →  config/kitty/
~/.config/noctalia   →  config/noctalia/
~/.config/rofi       →  config/rofi/
~/.config/zellij     →  config/zellij/
~/.config/easyeffects→  config/easyeffects/
```

## Applying the Configuration

> Requires NixOS with flakes enabled.

```bash
# Full system rebuild
sudo nixos-rebuild switch --flake .#nixos

# Home Manager only (user environment)
home-manager switch --flake .#yassine
```

## TODO

- [ ] Add Neovim config
- [ ] Add Tmux config
- [ ] Sync Noctalia theme changes across all programs (Chrome dark/light mode, terminal themes, etc.)

## Hardware Notes

- **Architecture**: `x86_64-linux`
- **Timezone**: `Europe/Paris`
- **Keyboard layout**: Swedish (`se`)
- **GPU**: Intel (VA-API via `intel-media-driver`)
- **Touchpad**: Synaptics with `psmouse.synaptics_intertouch=1` for proper multi-touch support
- **Bluetooth**: enabled with battery reporting and `blueman`
- **Virtualisation**: Docker (btrfs storage driver)
