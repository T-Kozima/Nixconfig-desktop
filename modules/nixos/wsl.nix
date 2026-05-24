{ pkgs, ... }:
{
  wsl.enable = true;
  wsl.defaultUser = "nixos";

  programs.fish.enable = true;
  users.users.nixos.shell = pkgs.fish;

  programs.starship.enable = true;
  programs.fish.interactiveShellInit = ''
    starship init fish | source
  '';

  programs.fish.shellAliases = {
   nr = "sudo nixos-rebuild switch --flake .#nixos";
   ll = "ls -l";
   gs = "git status";
  };
}
