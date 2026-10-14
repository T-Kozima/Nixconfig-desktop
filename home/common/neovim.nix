{ config, pkgs, ... }:

# デスクトップ(home/home.nix)と WSL(home/wsl.nix)の両方から import する共通モジュール。
# 設定ファイル本体は home/common/nvim/ にあり、~/.config/nvim からそこを直接指す。
let
  # 各ホストの home 設定で定義している FLAKE（= このリポジトリのチェックアウト先）を使う
  #   デスクトップ: /home/chronotokei/dotfiles
  #   WSL:          /home/nixos/nixconfig-desktop
  nvimDir = "${config.home.sessionVariables.FLAKE}/home/common/nvim";
in
{
  home.packages = [ pkgs.neovim ];

  # Nix ストアにコピーせず、リポジトリ内のディレクトリへのシンボリックリンクにする。
  # → init.lua を編集したら nixos-rebuild せずにそのまま反映される。
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink nvimDir;
}
