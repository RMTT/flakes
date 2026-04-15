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
      infra_node_ip = "198.19.198.3";
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

      systemd.network = {
        netdevs."10-ipv6net" = {
          netdevConfig = {
            Name = "ipv6net";
            Kind = "sit";
          };
          tunnelConfig = {
            Independent = true;
            Local = "104.194.71.122";
            Remote = "207.246.106.118";
            TTL = 255;
          };
        };
        networks."10-ipv6net" = {
          matchConfig.Name = "ipv6net";
          address = [
            "2607:8700:5501:183a::2/64"
          ];
          routes = [
            { routeConfig.Gateway = "2607:8700:5501:183a::1"; }
          ];
        };
      };

      services.godel = {
        infra-ip = infra_node_ip;
        overlay = {
          enable = true;
          xfrm = true;
        };
        k3s = {
          enable = true;
          interface = "godel";
          role = "agent";
        };
        uptime = {
          enable = true;
        };
      };

      services.cloudflare-tunnel = {
        enable = true;
        tokenFile = config.sops.secrets.tunnel.path;
      };
    };
}
