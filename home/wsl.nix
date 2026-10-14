{ pkgs, ... }:

# WSL 用の home-manager 設定。デスクトップ用 home/home.nix（niri・GTK など）は使わない。
{
  home.username = "nixos";
  home.homeDirectory = "/home/nixos";
  home.stateVersion = "26.05";
  programs.home-manager.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
    LANG = "ja_JP.UTF-8";
    FLAKE = "/home/nixos/nixconfig-desktop";
  };

  home.packages = with pkgs; [
    nh
    nix-output-monitor
    nix-tree
    comma
    fastfetch
    lazygit
    ghq
    ncdu
  ];

  programs.fish = {
    enable = true;
    shellAliases = {
      ll = "ls -l";
      gs = "git status";
    };
    # `uname -m` で x86_64 / aarch64 を選ぶ（flake.nix の wsl-<arch> に対応）
    functions.nr = ''
      sudo nixos-rebuild switch --flake $FLAKE#wsl-(uname -m) $argv
    '';
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      add_newline = false;
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
    };
  };
}
