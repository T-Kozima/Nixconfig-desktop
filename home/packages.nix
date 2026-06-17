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

       # 3. カラーテーマ (Catppuccin Mocha)
       # コントラストが強すぎず、niriのモダンな画面に調和します
       colors = {
         primary = {
           background = "0x1e1e2e";
           foreground = "0xcdd6f4";
           dim_foreground = "0x7f849c";
         };
         cursor = {
           text = "0x1e1e2e";
           cursor = "0xf5e0dc";
         };
         vi_mode_cursor = {
           text = "0x1e1e2e";
           cursor = "0xb4befe";
         };
         search = {
           matches = {
             foreground = "0x1e1e2e";
             background = "0xa6adc8";
           };
           focused_match = {
             foreground = "0x1e1e2e";
             background = "0xa6e3a1";
           };
         };
         hints = {
           start = {
             foreground = "0x1e1e2e";
             background = "0xf9e2af";
           };
           end = {
             foreground = "0x1e1e2e";
             background = "0xa6adc8";
           };
         };

         # 標準の16色パレット
         normal = {
           black = "0x45475a";
           red = "0xf38ba8";
           green = "0xa6e3a1";
           yellow = "0xf9e2af";
           blue = "0x89b4fa";
           magenta = "0xf5c2e7";
           cyan = "0x94e2d5";
           white = "0xbac2de";
         };
         bright = {
           black = "0x585b70";
           red = "0xf38ba8";
           green = "0xa6e3a1";
           yellow = "0xf9e2af";
           blue = "0x89b4fa";
           magenta = "0xf5c2e7";
           cyan = "0x94e2d5";
           white = "0xa6adc8";
         };
       };
     };
   };
}
