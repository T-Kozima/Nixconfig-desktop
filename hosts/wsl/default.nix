{ inputs, ... }:

# WSL 用ホスト。デスクトップ用の hosts/common（niri・SDDM・Bluetooth など）は
# 読み込まず、GUI 不要な共通モジュールだけを使う。
{
  imports = [
    inputs.nixos-wsl.nixosModules.wsl
    ../../modules/nixos/nix.nix
    ../../modules/nixos/docker.nix
    ../../modules/nixos/wsl.nix
    ../../modules/nixos/packages-cli.nix
  ];

  networking.hostName = "nixos-wsl";

  time.timeZone = "Asia/Tokyo";
  i18n.defaultLocale = "ja_JP.UTF-8";

  # docker は modules/nixos/docker.nix で有効化済み。WSL のユーザーを docker グループへ
  users.users.nixos.extraGroups = [ "wheel" "docker" ];

  system.stateVersion = "26.05";
}
