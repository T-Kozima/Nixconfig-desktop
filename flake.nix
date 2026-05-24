{
  description = "Chrono's NixOS WSL Flake";

  inputs = {
	#参照するパッケージのバージョンを指定
	nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
#	nixos-wsl.url = "github:nix-community/NixOS-WSL";
  };

  outputs = {self, nixpkgs, ... }: {
	nixosConfigurations.nixos = nixpkgs.lib.nixosSystem{
	  system = "x86_64-linux";
	  modules = [
#		nixos-wsl.nixosModules.wsl
		./configuration.nix
	  ];
	};
  };
}
