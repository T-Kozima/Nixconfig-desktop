{ pkgs, ...}:
{
 programs.nix-ld.enable = true;
 environment.systemPackages = with pkgs; [
   wget
   blueman
   gh
   docker-compose
   vscode.fhs
   wireshark
   neovim
   gnumake
   automake
   cmake
   gcc
   gdb
   nodejs
   tilix
   fzf
   direnv
   gnupg
   mpd
   htop
   ripgrep
   fd
   jq
   bat
   eza
   zoxide
   tmux
   rustup
   btop
   unzip
   tree
   curl
   awww
   alacritty
   (pkgs.catppuccin-sddm.override {
     flavor = "mocha";
     accent = "mauve";
     font = "Noto Sans";
     fontSize = "9";
     background = "${../../wallpapers/walls-catppuccin-mocha/3d-model.jpg}";

     loginBackground = true;
   })
 ];


}
