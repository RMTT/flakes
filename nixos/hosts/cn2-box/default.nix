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
    ./secrets
  ];

  config =
    let
      infra_node_ip = "192.168.128.6";
      infra_network = "fd97:1208:0:3::1/64";
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

      base.gl.enable = false;
      fs.normal.volumes = {
        "/" = {
          fsType = "ext4";
          device = "e0e4c021-ac04-4a4f-8937-0b2bd63109e5";
          options = [
            "noatime"
            "data=writeback"
            "barrier=0"
            "nobh"
            "errors=remount-ro"
          ];
        };
      };
      fs.swap.device = "b9d2021e-473b-408e-8363-a9d06418c99c";

      networking.firewall.allowedTCPPorts = [
        80
        443
      ];

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
        network = infra_network;
        extra_network = [
          "${infra_node_ip}/32"
          "10.42.3.0/24"
        ];
        extra_ip = [ "${infra_node_ip}/32" ];
        mode = "netns";
        public = true;

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
