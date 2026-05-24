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
    extraGroups = [ "wheel" "docker" ];
    shell = pkgs.fish;
  };
  
  users.users.kojimatakumi = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
  };

  programs.niri.enable = true;
  programs.fish.enable = true;
  
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.waylandFrontend = true;
    fcitx5.addons = [
      pkgs.fcitx5-mozc
      pkgs.fcitx5-gtk
    ];
  };

  fonts.packages = with pkgs; [
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
  ];
   


  xdg.portal = {
    enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
    config = {
      common = {
        default = ["gtk"];
      };
    };
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --remember-user-session --user-menu ja --cmd 'bash -l -c niri-session'";
        user = "greeter";
      };
    };
  };

  services.xserver.xkb = {
    layout = "jp";
    model = "jp106";
  };

  console.useXkbConfig = true;

  systemd.services.greeted.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal";
    TTYReset = true;
    TTYVHangup = true;
    TTYVDisallocate = true;
  };

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "25.11";
}
