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
		firefox
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
	];


}
