{ ... }:
{
  virtualisation.docker.enable = true;
  users.users.chronotokei.extraGroups = [ "docker"];
}
