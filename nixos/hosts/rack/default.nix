{
  pkgs,
  lib,
  config,
  modulesPath,
  ...
}:
with lib;
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./secrets
    ./disk-config.nix
  ];

  config =
    let
      infra_node_ip = "100.100.128.4";
      wan = "ens3";
    in
    {
      system.stateVersion = "25.05";

      hardware.cpu.intel.updateMicrocode = true;
      networking.useNetworkd = true;

      machine.graphics.enable = false;
      boot.loader.systemd-boot.enable = lib.mkForce false;
      boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
      boot.loader.grub = {
        enable = lib.mkForce true;
      };
      zramSwap = {
        enable = true;
        memoryPercent = 25;
      };

      services.godel = {
        enable = true;
        extra_routes = "10.42.0.0/24";
        k3s = {
          enable = true;
          node-ip = infra_node_ip;
          role = "server";
        };
      };

    };
}
