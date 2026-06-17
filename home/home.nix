{ config, pkgs, lib ,... }:

{
  # ユーザー情報の定義
  home.username = "chronotokei";
  home.homeDirectory = "/home/chronotokei";

  # 💡 ここで「ユーザー専用のパッケージリスト」を読み込みます
  imports = [
    ./packages.nix
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
      name = "catppuccin-mocha-mauve-standard+default";
      package = pkgs.catppuccin-gtk.override {
        accents = ["mauve"];
        size = "standard";
        tweaks = ["normal"];
        variant = "mocha";
      };
    };
    iconTheme = {
      name = "Papirus-Dark";
      package  =pkgs.catppuccin-papirus-folders.override {
        flavor = "mocha";
        accent = "mauve";
      };
    };
    cursorTheme = {
      name = "catppuccin-mocha-mauve-cursors";
      package = pkgs.catppuccin-cursors.mochaMauve;
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


  # 💡 footターミナルの設定（Catppuccin Mocha テーマ）
    programs.foot = {
      enable = true;
      settings = {
        main = {
          font = "monospace:size=12"; # 📝 お好みのフォントサイズに変更可能です
          pad = "12x12 center";       # ターミナル内の余白（少し空けると美しくなります）
        };

        # 💡 Catppuccin Mocha の公式カラーパレット
        "colors-dark" = {
          alpha = "0.95";             # 背景の透過度（1.0で不透明、少し下げると背景が透けます）
          background = "1e1e2e";      # Base
          foreground = "cdd6f4";      # Text

          # 通常カラー (Black, Red, Green, Yellow, Blue, Magenta, Cyan, White)
          regular0 = "45475a";        # Surface 1
          regular1 = "f38ba8";        # Red
          regular2 = "a6e3a1";        # Green
          regular3 = "f9e2af";        # Yellow
          regular4 = "89b4fa";        # Blue
          regular5 = "f5c2e7";        # Pink
          regular6 = "94e2d5";        # Teal
          regular7 = "bac2de";        # Subtext 1

          # ブライトカラー（太字などで使われる明るい色）
          bright0 = "585b70";         # Surface 2
          bright1 = "f38ba8";         # Red
          bright2 = "a6e3a1";         # Green
          bright3 = "f9e2af";         # Yellow
          bright4 = "89b4fa";         # Blue
          bright5 = "f5c2e7";         # Pink
          bright6 = "94e2d5";         # Teal
          bright7 = "a6adc8";         # Subtext 0
        };
      };
    };
    # 💡 Fuzzel（アプリケーションランチャー）のモダン化・テーマ設定
      programs.fuzzel = {
        enable = true;
        settings = {
          # 全体のレイアウトと挙動の設定
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

          # Catppuccin Mocha (Mauveアクセント) のカラー設定
          colors = {
            background = "1e1e2ee6";    # Base (e6 = 不透明度90%)
            text = "cdd6f4ff";          # Text
            match = "cba6f7ff";         # Mauve (検索一致部分のハイライト)
            selection = "585b70ff";     # Surface 2 (選択中の背景)
            selection-text = "cdd6f4ff";# Text
            border = "cba6f7ff";        # Mauve (枠線)
          };

          # 枠線と角丸の設定（モダンな見た目の要）
          border = {
            width = 2;
            radius = 12;
          };
        };
      };



}
