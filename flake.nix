{
  description = "Chrono's NixOS Flake";

  # 💡 1. Home Manager の入力（Inputs）を追加します
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 👈 ここを追加
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # WSL 向け（hosts/wsl だけが使う。デスクトップ構成には影響しない）
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # 💡 2. 引数（Outputs）に home-manager を受け取ります
  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      # WSL ホストを system（CPU アーキテクチャ）ごとに作る関数
      mkWsl = system: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/wsl/default.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.nixos = import ./home/wsl.nix;
          }
        ];
      };
    in
    {
      nixosConfigurations = {
        # 👇 ここは今動いているマシンのホスト名（おそらく "nixos"）に合わせます
        nixos = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };

          modules = [
            ./hosts/nixos/default.nix
            ./noctalia.nix
            # 💡 3. ここで Home Manager のモジュールをシステムに合体させます！
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              # 👇 Chronoさん専用の home.nix を読み込む配線
              home-manager.users.chronotokei = import ./home/home.nix;
            }
          ];
        };

        # WSL 用。WSL 内の `uname -m` に合わせて選ぶ
        #   x86_64  -> .#wsl-x86_64
        #   aarch64 -> .#wsl-aarch64 (Snapdragon 搭載 PC など)
        wsl-x86_64 = mkWsl "x86_64-linux";
        wsl-aarch64 = mkWsl "aarch64-linux";
      };
    };
}
