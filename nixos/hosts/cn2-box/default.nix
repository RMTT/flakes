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
    ./secrets
  ];

  config =
    let
      infra_node_ip = "198.19.19.20";
      wan = "eth0";
    in
    {
      system.stateVersion = "25.05";

      hardware.cpu.amd.updateMicrocode = true;
      networking.useNetworkd = true;

      boot.loader.systemd-boot.enable = lib.mkForce false;
      boot.loader.grub.enable = lib.mkForce true;
      boot.loader.grub.device = "/dev/sda";
      boot.loader.efi.canTouchEfiVariables = lib.mkForce false;

      machine.graphics.enable = false;
      fileSystems = {
        "/" = {
          options = [
            "noatime"
            "data=writeback"
            "barrier=0"
            "nobh"
            "errors=remount-ro"
          ];
          fsType = "ext4";
          device = "UUID=e0e4c021-ac04-4a4f-8937-0b2bd63109e5";
        };
      };
      swapDevices = [ { device = "/dev/disk/by-uuid/b9d2021e-473b-408e-8363-a9d06418c99c"; } ];

      networking.firewall.allowedTCPPorts = [
        80
        443
      ];

      services.godel = {
        overlay = {
          enable = true;
          extra_routes = [ "10.42.1.0/24" ];
          ip = infra_node_ip;
        };
        k3s = {
          enable = true;
          node-ip = infra_node_ip;
          role = "agent";
        };
      };
      services.prometheus = {
        exporters.node.enable = true;
      };
    };
}
