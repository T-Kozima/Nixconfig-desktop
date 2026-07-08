{ config, lib, pkgs, ... }:

{
  imports = [
    ../../modules/nixos/nix.nix
    ../../modules/nixos/docker.nix
    ../../modules/nixos/i18n.nix
    ../../modules/nixos/packages.nix
  ];

  # ユーザー設定
  users.users.chronotokei = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "bluetooth" "networkmanager" "audio" "video" ];
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
    noto-fonts
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
        default = lib.mkForce [ "hyprland" "gtk" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "hyprland" ];
      };
      common = {
        default = [ "hyprland" "gtk" ];
      };
    };
  };

  services.xserver= {
    xkb = {
      layout = "jp";
      model = "jp106";
    };
    enable = true;
  };

  console.useXkbConfig = true;

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = false;
    theme = "catppuccin-mocha-mauve";
    package  = pkgs.kdePackages.sddm;
    settings = {
      Theme = {
        CursorTheme = "Vanilla-DMZ";
      };
    };
  };

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

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "electron-39.8.10"
  ];

}
