{ pkgs, inputs, ... }: {
  home.packages = with pkgs; [
    waybar
    rofi
    mako
    swww
    wl-clipboard
    grim
    slurp
    google-chrome
    vscode
    hyprpolkitagent
    pavucontrol
    hyprshot
    hyprpicker
    cliphist
    playerctl
    brightnessctl
    nautilus
    libinput
    libsecret
    zsh
    oh-my-zsh
    nerd-fonts.jetbrains-mono
    font-awesome
    noto-fonts
    noto-fonts-color-emoji
    fastfetch
    zellij
    fd
    bat
    ripgrep
    alacritty
    htop
    btop

    # Lock screen & idle
    hyprlock
    hypridle
    # swayidle
    # swaylock

    # Secrets / keyring
    gnome-keyring

    # OCR
    tesseract

    # Cursor theme
    bibata-cursors

    # Audio effects
    easyeffects

    # Browser
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}