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
      infra_node_ip = "198.19.198.2";
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

      services.uptime-kuma = {
        enable = true;
        settings = {
          UPTIME_KUMA_HOST = "127.0.0.1";
          UPTIME_KUMA_PORT = "3001";
        };
      };

      systemd.services.uptime-kuma.path = [ pkgs.cloudflared ];

      services.godel = {
        enable = true;
        extra_routes = [ "10.42.0.0/24" ];
        ip = infra_node_ip;
        k3s = {
          enable = false;
          node-ip = infra_node_ip;
          role = "agent";
        };
      };
    };
}
