{ pkgs, ... }:

# NixOS-WSL 固有の設定（hosts/wsl だけが import する）
{
  wsl = {
    enable = true;
    defaultUser = "nixos";
    # Windows の PATH / exe を WSL から呼べるようにする（既定値を明示）
    interop.includePath = true;
    # Windows のスタートメニューに WSL 内の GUI アプリのショートカットを作る
    startMenuLaunchers = true;
  };

  # ログインシェルは fish。starship / alias は home-manager 側(home/wsl.nix)で設定する
  programs.fish.enable = true;
  users.users.nixos.shell = pkgs.fish;
}
