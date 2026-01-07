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
    ./disk-config.nix
  ];

  config =
    let
      infra_node_ip = "100.100.128.1";
      home_node_ip = "198.19.19.4/24";
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
        address = [ home_node_ip ];
        gateway = [ "198.19.19.10" ];
        dns = [ "198.19.19.1" ];
      };
      machine.secrets.enable = true;
      services.godel = {
        enable = true;
        extra_routes = "10.42.2.0/24";
        k3s = {
          enable = true;
          node-ip = infra_node_ip;
          node-labels = [ "intel.feature.node.kubernetes.io/gpu=true" ];
          role = "agent";
        };
      };
    };
}
