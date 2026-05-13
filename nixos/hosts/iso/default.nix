{ lib, ... }:
{
  machine.users.mt.enable = false;

  nixpkgs.hostPlatform = "x86_64-linux";
}
