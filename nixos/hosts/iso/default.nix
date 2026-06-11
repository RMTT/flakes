{ lib, ... }:
{
  machine.users.mt.enable = false;

  nixpkgs.hostPlatform = "x86_64-linux";
  machine.bootloader.systemd-boot.enable = lib.mkDefault true;
}
