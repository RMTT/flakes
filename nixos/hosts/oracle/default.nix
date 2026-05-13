{
  pkgs,
  lib,
  config,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/virtualisation/oci-image.nix")
    ./disko.nix
  ];

  config = {
    machine.graphics.enable = false;
    machine.bootloader.enable = false;
    system.stateVersion = "26.05";
    nixpkgs.hostPlatform = "aarch64-linux";

    boot.kernelParams = [ "net.ifnames=0" ];
    networking.hostName = "oracle";
  };
}
