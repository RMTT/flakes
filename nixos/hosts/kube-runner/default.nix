{
  pkgs,
  lib,
  config,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
    ./secrets
  ];

  config =
    let
      infra_node_ip = "198.19.19.4";
    in
    {
      system.stateVersion = "25.11";

      networking.useNetworkd = true;
      networking.useDHCP = false;
      machine.graphics.enable = false;
      services.qemuGuest.enable = true;
      zramSwap = {
        enable = true;
        memoryPercent = 20;
      };

      systemd.network.networks.wan = {
        matchConfig.Name = "ens18";
        address = [ "${infra_node_ip}/24" ];
        gateway = [ "198.19.19.1" ];
        dns = [ "198.19.19.1" ];
      };
      machine.secrets.enable = true;

      services.godel = {
        infra-ip = infra_node_ip;
        k3s = {
          enable = true;
          role = "server";
          interface = "ens18";
        };
      };
    };
}
