{ pkgs, ...}:
let randomWallpaper = pkgs.writeShellScriptBin "random-wallpaper" ''
     WALLPAPER_DIR="$HOME/dotfiles/wallpapers"
     if [ ! -d "$WALLPAPER_DIR" ] || [ -z "$(ls -A "$WALLPAPER_DIR")" ]; then
       exit 0
     fi

     SELECTED_IMG=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" \)| shuf -n 1)
     exec ${pkgs.wbg}/bin/wbg "$SELECTED_IMG"

   '';
in
{
	home.packages = with pkgs; [
		obsidian
		git
		zed-editor
		wbg
		quickshell
		qt6.qtwayland
		qt6.qtsvg
		qt6.qtdeclarative

		hyprpicker
		pamixer
		brightnessctl
		randomWallpaper
		thunar
		thunar-volman
		thunar-archive-plugin
		file-roller
		tumbler
		bitwarden-desktop
		rbw
		rofi-rbw-wayland
		pinentry-gnome3
		floorp-bin
		fastfetch
		starship
		nh
		nix-output-monitor
		comma
		nix-tree
		lazygit
		ghq
		ncdu
	];

	programs.fish.enable = true;
	programs.starship = {
	  enable = true;
	  enableFishIntegration = true;
	  settings = {
	    add_newline = false;
	    # キャラクター（入力待ちの矢印）のカスタム例
	    character = {
	      success_symbol = "[➜](bold green)";
	      error_symbol = "[➜](bold red)";
	    };
	  };
	};
	programs.alacritty = {
     enable = true;
     settings = {
       # 1. ウィンドウの見た目・デザイン
       window = {
         # ターミナルの端に文字が張り付かないように余白（パディング）を設定
         padding = {
           x = 12;
           y = 12;
         };
         # 背景の透過度（0.0 が完全透明、1.0 が完全不透明）
         opacity = 0.90;

         # タイトルバーや境界線の装飾設定（niri側で制御するため基本は無し、またはNone）
         decorations = "None";

         # 起動時のデフォルトサイズ
         dimensions = {
           columns = 90;
           lines = 24;
         };
       };

       # 2. フォント設定
       font = {
         normal = {
           family = "Noto Sans Mono";
           style = "Regular";
         };
         bold = {
           family = "Noto Sans Mono";
           style = "Bold";
         };
         italic = {
           family = "Noto Sans Mono";
           style = "Italic";
         };
         size = 11.0;
       };

        # 3. カラーテーマ (Tokyo Night Storm)
        colors = {
          primary = {
            background = "0x1a1b26";
            foreground = "0xc0caf5";
            dim_foreground = "0xa9b1d6";
          };
          cursor = {
            text = "0x1a1b26";
            cursor = "0xc0caf5";
          };
          vi_mode_cursor = {
            text = "0x1a1b26";
            cursor = "0x7aa2f7";
          };
          search = {
            matches = {
              foreground = "0x1a1b26";
              background = "0x3b4261";
            };
            focused_match = {
              foreground = "0x1a1b26";
              background = "0x9ece6a";
            };
          };
          hints = {
            start = {
              foreground = "0x1a1b26";
              background = "0xe0af68";
            };
            end = {
              foreground = "0x1a1b26";
              background = "0x3b4261";
            };
          };

          # 標準の16色パレット
          normal = {
            black = "0x15161e";
            red = "0xf7768e";
            green = "0x9ece6a";
            yellow = "0xe0af68";
            blue = "0x7aa2f7";
            magenta = "0xbb9af7";
            cyan = "0x7dcfff";
            white = "0xa9b1d6";
          };
          bright = {
            black = "0x414868";
            red = "0xf7768e";
            green = "0x9ece6a";
            yellow = "0xe0af68";
            blue = "0x7aa2f7";
            magenta = "0xbb9af7";
            cyan = "0x7dcfff";
            white = "0xc0caf5";
          };
        };
     };
   };
}
