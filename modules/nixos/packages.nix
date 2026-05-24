{ pkgs, ...}:
{
 programs.nix-ld.enable = true;
 environment.systemPackages = with pkgs; [
   wget
   nix-ld
   git
   gh
   docker-compose
   fish
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
   firefox
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
   foot
   fuzzel
   zed-editor
   waybar
  ];
  
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
