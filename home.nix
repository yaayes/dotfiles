{ pkgs, inputs, lib, config, ... }:

let
  dotfiles = "/home/yassine/dotfiles";

  # ── Catppuccin theme files (fetched directly from github.com/catppuccin) ──
  # To change flavor: swap the filename (latte/frappe/macchiato/mocha)
  alacrittyTheme = pkgs.fetchurl {
    url    = "https://raw.githubusercontent.com/catppuccin/alacritty/main/catppuccin-mocha.toml";
    sha256 = "1idjbm5jim9b36235hgwgp9ab81fmbij42y7h85l4l7cqcbyz74l";
  };
  kittyTheme = pkgs.fetchurl {
    url    = "https://raw.githubusercontent.com/catppuccin/kitty/main/themes/mocha.conf";
    sha256 = "1kgr1vi9n083w3xw8ndwqkh03w74ma0ajg5m6pzy9fj2smycjski";
  };
  rofiTheme = pkgs.fetchurl {
    url    = "https://raw.githubusercontent.com/catppuccin/rofi/main/themes/catppuccin-mocha.rasi";
    sha256 = "0ikn0yc2b9cyzk4xga8mcq1j7xk2idik4wzpsibrphy8qr2pla4b";
  };
  zellijTheme = pkgs.fetchurl {
    url    = "https://raw.githubusercontent.com/catppuccin/zellij/main/catppuccin.kdl";
    sha256 = "12ha4zpg769671jx4ycb2vg79svhb6j8gnd3xlvyxf96bgzf97in";
  };
  hyprlandTheme = pkgs.fetchurl {
    url    = "https://raw.githubusercontent.com/catppuccin/hyprland/main/themes/mocha.conf";
    sha256 = "0513j8wbh50jah2r0h48sw9jfw8w0h6w8z90vg0f6zk3jsyls5ab";
  };
  zshSyntaxTheme = pkgs.fetchurl {
    url    = "https://raw.githubusercontent.com/catppuccin/zsh-syntax-highlighting/main/themes/catppuccin_mocha-zsh-syntax-highlighting.zsh";
    sha256 = "1x2105vl3iiym9a5b6zsclglff4xy3r4iddz53dnns7djy6cf21d";
  };

  # ── Config symlinks ───────────────────────────────────────────
  # Each entry maps ~/.config/<key> to ./config/<value> as a live
  # out-of-store symlink — edits take effect without home-manager switch.
  configLinks = {
    "zellij"      = "${dotfiles}/config/zellij";
    "rofi"        = "${dotfiles}/config/rofi";
    "easyeffects" = "${dotfiles}/config/easyeffects";
    "noctalia"    = "${dotfiles}/config/noctalia";
    "kitty"       = "${dotfiles}/config/kitty";
    "alacritty"   = "${dotfiles}/config/alacritty";
    "hypr"        = "${dotfiles}/config/hypr";
    # "waybar"    = "${dotfiles}/config/waybar";  # disabled — using noctalia-shell
  };
in

{
    home.username = "yassine";
    home.homeDirectory = "/home/yassine";
    home.stateVersion = "25.11";
    programs.home-manager.enable = true;
    fonts.fontconfig.enable = true;

    home.sessionVariables = {
      XDG_SESSION_TYPE = "wayland";
      NIXOS_OZONE_WL = "1";
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
      XCURSOR_THEME = "Bibata-Modern-Classic";
      XCURSOR_SIZE = "24";
      ZSH = "${pkgs.oh-my-zsh}/share/oh-my-zsh";
    };

    imports = [
      ./packages.nix
      inputs.noctalia.homeModules.default
    ];

    programs.noctalia-shell = {
      enable = true;
    };
    services.mako.enable = true;

    # ── Yazi (TUI file manager) ────────────────────────────────
    programs.yazi = {
      enable = true;
      shellWrapperName = "y";
      plugins = with pkgs.yaziPlugins; {
        inherit git sudo diff rsync lazygit chmod;
      };
    };

    # ── Hyprland ────────────────────────────────────────────────
    # Config files live in ./config/hypr/ (symlinked via configLinks).
    # Theme colors come from hypr/mocha.conf (fetched via hyprlandTheme).
    # Idle management and lock screen are handled by noctalia-shell.

    wayland.windowManager.hyprland = {
      enable = true;
      # Config lives in dotfiles/config/hypr/ (symlinked via configLinks).
      # Disable HM's config generation to avoid conflict with the dir symlink.
      systemd.enable = false;
    };

    # ── Zsh ─────────────────────────────────────────────────
    # The actual .zshrc lives in config/zsh/.zshrc — a portable file that
    # works on any distro.  We simply symlink it into ~/ so edits are live.
    # System-level configuration.nix sets zsh as the login shell.
    home.file.".zshrc".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfiles}/config/zsh/.zshrc";

    # ── Config symlinks (generated from configLinks above) ────
    xdg.configFile = lib.mapAttrs (dest: src: {
      source = config.lib.file.mkOutOfStoreSymlink src;
      recursive = true;
    }) configLinks // {
      # Zsh catppuccin syntax theme — lives in dotfiles repo, symlinked here
      # (zsh dir is not in configLinks so we handle it explicitly)
      "zsh/catppuccin-syntax.zsh".source =
        config.lib.file.mkOutOfStoreSymlink "${dotfiles}/config/zsh/catppuccin-syntax.zsh";

      "chrome-flags.conf".source =
        config.lib.file.mkOutOfStoreSymlink "${dotfiles}/config/chrome/chrome-flags.conf";
    };
}
