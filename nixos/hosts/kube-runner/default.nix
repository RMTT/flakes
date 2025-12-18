{
  pkgs,
  lib,
  config,
  modules,
  modulesPath,
  ...
}:
with lib;
{
  imports = with modules; [
    base
    fs
    networking
    globals
    godel
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
  ];

  config =
    let
      infra_node_ip = "100.100.128.1";
    in
    {
      system.stateVersion = "25.11";

      hardware.cpu.amd.updateMicrocode = true;
      networking.useNetworkd = true;
      base.gl.enable = false;
      virtualisation.incus.agent.enable = true;

      services.godel = {
        enable = true;
        extra_routes = "10.42.1.0/24";
        k3s = {
          enable = true;
          node-ip = infra_node_ip;
          node-labels = [ "intel.feature.node.kubernetes.io/gpu=true" ];
          role = "agent";
        };
      };
    };
}
