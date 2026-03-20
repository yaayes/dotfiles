# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:

let
  # Change this to switch theme variant without logging out.
  # Available variants: astronaut, black_hole, cyberpunk, hyprland_kath,
  # jake_the_dog, japanese_aesthetic, pixel_sakura, pixel_sakura_static,
  # post-apocalyptic_hacker, purple_leaves
  sddmThemeVariant = "astronaut";

  sddm-astronaut-theme-pkg = pkgs.stdenv.mkDerivation {
    name = "sddm-astronaut-theme";
    src = inputs.sddm-astronaut-theme;
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/share/sddm/themes/sddm-astronaut-theme
      cp -r . $out/share/sddm/themes/sddm-astronaut-theme/
      sed -i "s|^ConfigFile=.*|ConfigFile=Themes/${sddmThemeVariant}.conf|" \
        $out/share/sddm/themes/sddm-astronaut-theme/metadata.desktop
    '';
  };

  sddm-astronaut-fonts = pkgs.runCommand "sddm-astronaut-fonts" { } ''
    mkdir -p $out/share/fonts/truetype/sddm-astronaut
    cp -r ${inputs.sddm-astronaut-theme}/Fonts/* $out/share/fonts/truetype/sddm-astronaut/
  '';
in

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

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver   # VA-API for CometLake (Gen 9.5+)
      intel-compute-runtime
    ];
  };

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

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.groups.yassine = {
    gid = 1000;
  };

  users.users.yassine = {
     isNormalUser = true;
     uid = 1000;
     group = "yassine";
     shell = pkgs.zsh;
     extraGroups = [ "wheel" "networkmanager" "docker" ];
  };
  programs.zsh.enable = true;

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

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "sddm-astronaut-theme";
    extraPackages = with pkgs; [
      qt6Packages.qtsvg
      qt6Packages.qtmultimedia
      qt6Packages.qtvirtualkeyboard
      qt6Packages.qt5compat
      gst_all_1.gstreamer
      gst_all_1.gst-plugins-base
      gst_all_1.gst-plugins-good
      gst_all_1.gst-plugins-bad
      gst_all_1.gst-libav
    ];
  };

  environment.variables = {
    QML_IMPORT_PATH = with pkgs; lib.makeSearchPathOutput "lib" "lib/qt-6/qml" [
      qt6Packages.qtmultimedia
      qt6Packages.qtsvg
      qt6Packages.qtvirtualkeyboard
      qt6Packages.qt5compat
    ];
  };
  services.displayManager.defaultSession = "hyprland";

  # programs.firefox.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
     vim
     kitty
     firefox
     git
     sddm-astronaut-theme-pkg
  ];
  environment.shells = with pkgs; [ zsh ];
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ] ++ [ sddm-astronaut-fonts ];

  system.stateVersion = "25.11";

}
