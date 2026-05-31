{
  description = "Chrono's NixOS Flake";

  # 💡 1. Home Manager の入力（Inputs）を追加します
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    # 👈 ここを追加
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # 💡 2. 引数（Outputs）に home-manager を受け取ります
  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations = {
      # 👇 ここは今動いているマシンのホスト名（おそらく "nixos"）に合わせます
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        
        modules = [
          ./configuration.nix
          
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
    };
  };
}
