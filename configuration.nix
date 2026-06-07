{ config, lib, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./modules/nixos/nix.nix
   # ./modules/nixos/wsl.nix
    ./modules/nixos/docker.nix
    ./modules/nixos/i18n.nix
    ./modules/nixos/packages.nix
  ];
# boot loader settings
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
# user settings
  users.users.chronotokei = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "bluetooth" "networkmanager" "audio" "video"];
    shell = pkgs.fish;
  };

  users.users.kojimatakumi = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
  };

  programs.fish.enable = true;
  programs.dconf.enable = true;
  programs.xwayland.enable = true;
  programs.niri.enable = true;




  fonts.packages = with pkgs; [
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
  ];


  environment.sessionVariables = {
     XDG_CURRENT_DESKTOP = "niri";
     NIXOS_OZONE_WL = "1";
  };

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];
    config = {
      niri = {
        default = lib.mkForce  [ "hyprland" "gtk" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "hyprland" ];
      };
      common = {
        default = [ "hyprland" "gtk" ];
      };
    };
  };



  services.xserver.xkb = {
    layout = "jp";
    model = "jp106";
  };

  console.useXkbConfig = true;

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "catppuccin-mocha-mauve";
    package  = pkgs.kdePackages.sddm;
  };

  # services.displayManager.sessionPackages のブロックを丸ごとこれに置き換え
  services.displayManager.sessionPackages = [
    (pkgs.runCommand "niri-session-desktop" {
      passthru.providedSessions = [ "niri" ];
    } ''
      mkdir -p $out/share/wayland-sessions
      cat > $out/share/wayland-sessions/niri.desktop << EOF
      [Desktop Entry]
      Name=Niri
      Comment=A scrollable-tiling Wayland compositor
      Exec=${pkgs.niri}/bin/niri-session
      Type=Application
      DesktopNames=niri
      EOF
    '')
  ];
  system.stateVersion = "26.05";

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;
  hardware.enableRedistributableFirmware = true;
  hardware.firmware = [ pkgs.linux-firmware ];
  boot.kernelPackages = pkgs.linuxPackages_6_12;
  boot.kernelPatches = [
    {
      name = "btusb-add-13d3-3614-mt7922";
      patch = ./btusb-mt7922-3614.patch;
    }
  ];
  nixpkgs.config.allowUnfree = true;
}
