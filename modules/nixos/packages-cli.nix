{ pkgs, ... }:

# modules/nixos/packages.nix から GUI・ハードウェア依存のものを除いた CLI 専用版
{
  programs.nix-ld.enable = true;

  environment.systemPackages = with pkgs; [
    wget
    curl
    git
    gh
    docker-compose
    neovim
    gnumake
    automake
    cmake
    gcc
    gdb
    nodejs
    fzf
    direnv
    gnupg
    htop
    btop
    ripgrep
    fd
    jq
    bat
    eza
    zoxide
    tmux
    rustup
    unzip
    tree
  ];
}
