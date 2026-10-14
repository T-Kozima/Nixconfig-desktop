{ config, pkgs, lib ,... }:

{
  # ユーザー情報の定義
  home.username = "chronotokei";
  home.homeDirectory = "/home/chronotokei";

  # 💡 ここで「ユーザー専用のパッケージリスト」を読み込みます
  imports = [
    ./packages.nix
    ./common/neovim.nix
  ];

  # バージョン指定（configuration.nixに合わせるか、最新の24.05にします）
  home.stateVersion = "26.05";
  programs.home-manager.enable = true;

  home.sessionVariables = {
    FLAKE = "/home/chronotokei/dotfiles";
    EDITOR = "zed-editor";
    LANG = "ja_JP.UTF-8";
  };


  gtk = {
    enable = true;
    theme = {
      name = "TokyoNight-Dark";
      package = pkgs.tokyonight-gtk-theme;
    };
    iconTheme = {
      name = "WhiteSur-dark";
      package = pkgs.whitesur-icon-theme;
    };
    cursorTheme = {
      name = "WhiteSur-cursors";
      package = pkgs.whitesur-cursors;
      size = 24;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style.name = "adwaita-dark";
  };

  xdg.configFile."niri/config.kdl".source = ./niri.kdl;
  xdg.configFile."quickshell".source = ./quickshell;

  gtk.gtk4.theme = config.gtk.theme;

  # 💡 footターミナルの設定（Tokyo Night Storm テーマ）
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "monospace:size=12";
        pad = "12x12 center";
      };

      # 💡 Tokyo Night Storm のカラーパレット
      "colors-dark" = {
        alpha = "0.90";
        background = "1a1b26";
        foreground = "c0caf5";

        regular0 = "15161e"; # Black
        regular1 = "f7768e"; # Red
        regular2 = "9ece6a"; # Green
        regular3 = "e0af68"; # Yellow
        regular4 = "7aa2f7"; # Blue
        regular5 = "bb9af7"; # Magenta
        regular6 = "7dcfff"; # Cyan
        regular7 = "a9b1d6"; # White

        bright0 = "414868";  # Bright Black
        bright1 = "f7768e";  # Bright Red
        bright2 = "9ece6a";  # Bright Green
        bright3 = "e0af68";  # Bright Yellow
        bright4 = "7aa2f7";  # Bright Blue
        bright5 = "bb9af7";  # Bright Magenta
        bright6 = "7dcfff";  # Bright Cyan
        bright7 = "c0caf5";  # Bright White
      };
    };
  };

  # 💡 Fuzzel（アプリケーションランチャー）のモダン化・テーマ設定（Tokyo Night Storm）
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "monospace:size=14";
        terminal = "${pkgs.foot}/bin/foot";
        prompt = "❯ ";
        lines = 10;
        width = 45;
        horizontal-pad = 20;
        vertical-pad = 20;
        inner-pad = 10;
      };

      colors = {
        background = "1a1b26e6";    # Base (e6 = 不透明度90%)
        text = "c0caf5ff";          # Text
        match = "ff9e64ff";         # Orange (検索一致部分のハイライト)
        selection = "3b4261ff";     # Selection Background
        selection-text = "c0caf5ff";# Text
        border = "7aa2f7ff";        # Blue Border
      };

      border = {
        width = 2;
        radius = 16;                # macOS風の丸み
      };
    };
  };



}
