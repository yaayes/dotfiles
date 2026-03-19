# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Enable SMBus/RMI multi-touch path for Synaptics touchpad so libinput
  # receives proper multi-touch events (required for 3-finger gestures).
  boot.kernelParams = [ "psmouse.synaptics_intertouch=1" ];

  networking.hostName = "nixos"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Configure keymap in X11
  services.xserver.xkb.layout = "se";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  services.pipewire = {
     enable = true;
     pulse.enable = true;
  };

  # Enable touchpad support via libinput (required for multi-touch gestures).
  services.libinput.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;  # battery reporting for BT devices
      };
    };
  };
  services.blueman.enable = true;
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  nixpkgs.config = {
    allowUnfree = true;
  };

  nixpkgs.overlays = [
    (final: prev: {
      noctalia-shell = prev.stdenv.mkDerivation {
        pname = "noctalia-shell";
        version = "4.5.0";
        src = prev.fetchzip {
          url = "https://github.com/noctalia-dev/noctalia-shell/archive/refs/tags/v4.5.0.tar.gz";
          hash = "sha256-Y5P0RYO9NKxa4UZBoGmmxtz3mEwJrBOfvdLJRGjV2Os=";
        };
        buildInputs = [ prev.qt6.qtbase prev.qt6.qtmultimedia ];
        nativeBuildInputs = [ prev.qt6.wrapQtAppsHook ];
        dontBuild = true;
        installPhase = ''
          runHook preInstall
          mkdir -p $out/share/noctalia-shell $out/bin
          ln -s ${prev.quickshell}/bin/qs $out/bin/noctalia-shell
          cp -R Assets Commons CREDITS.md Helpers Modules Services Shaders Scripts Widgets shell.qml \
            $out/share/noctalia-shell
          rm -rf $out/share/noctalia-shell/Assets/Screenshots
          runHook postInstall
        '';
        preFixup = ''
          qtWrapperArgs+=(
            --add-flags "-p $out/share/noctalia-shell"
          )
        '';
        meta.mainProgram = "noctalia-shell";
      };
    })
  ];

  # Enable zsh system-wide (required when using it as default shell).
  programs.zsh.enable = true;

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.groups.yassine = {
    gid = 1000;
  };

  users.users.yassine = {
     isNormalUser = true;
     uid = 1000;
     group = "yassine";
     extraGroups = [ "wheel" "networkmanager" "docker" ]; # Enable 'sudo' for the user.
     shell = pkgs.zsh;
  };

  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";
  };

  security.sudo.wheelNeedsPassword = true;
  security.rtkit.enable= true;

  # Start gnome-keyring via PAM on login so GNOME_KEYRING_CONTROL is set
  # correctly and VS Code can use it for encryption key storage.
  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.sddm.enableGnomeKeyring = true;
  services.gnome.gnome-keyring.enable = true;
  programs.hyprland.enable = true;

  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.defaultSession = "hyprland";

  # programs.firefox.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
     vim
     kitty
     firefox
     git
    #  waybar
    #  wofi
    #  home-manager
    #  zsh
    #  libsecret  # required for VS Code gnome-libsecret password store
    #  noctalia-shell  # pinned as GC root — survives nix-collect-garbage
  ];
  environment.shells = with pkgs; [ zsh ];
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];
  # Prevent the new user dialog in zsh
  system.userActivationScripts.zshrc = "touch .zshrc";

  system.stateVersion = "25.11"; # Did you read the comment?

}
