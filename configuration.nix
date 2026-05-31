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

  programs.fish.enable = true;
  programs.dconf.enable = true;
  programs.xwayland.enable = true;
  programs.niri.enable = true;

  programs.regreet = {
	enable = true;
	theme = {
		name = "Adwaita-dark";
		package = pkgs.gnome-themes-extra;
	};
	iconTheme = {
		name = "Adwaita";
		package = pkgs.adwaita-icon-theme;
	};
	cursorTheme = {
		name = "Adwaita";
		package = pkgs.adwaita-icon-theme;
	};

	settings = {
		background = {
			path = ./wallpaper_cosmos.png;
			fit = "Cover";
		};
		GTK = {
			application_prefer_dark_theme = true;
		};
	};

  };


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

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.cage}/bin/cage -s -- ${pkgs.regreet}/bin/regreet";
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
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "25.11";

}
