{ ... }:
{

  #Nix settings
  nix.settings = {
  	experimental-features = [ "nix-command" "flakes" ];
	auto-optimise-store = true;
  };

  # garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  nixpkgs.config.allowUnfree = true;
}
