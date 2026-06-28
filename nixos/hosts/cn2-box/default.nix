{
  pkgs,
  lib,
  config,
  modulesPath,
  ...
}:
let
  infra_ip = "198.19.20.2";
  external_ip = "147.224.143.231";
in
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./secrets
  ];

  config = {
    system.stateVersion = "25.05";

    hardware.cpu.amd.updateMicrocode = true;
    networking.useNetworkd = true;

    nixpkgs.hostPlatform = "x86_64-linux";
    machine.bootloader.grub = {
      enable = true;
      device = "/dev/sda";
    };
    machine.users.mt.hashedPassword = "$y$j9T$7WSe/8Z5o/MjnsDZ578rS.$/U15tOTTptiayopi2AKSH3kQz98hH5/KUIDvUVHzsX6";

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
          { Gateway = "2607:8700:5501:183a::1"; }
        ];
      };
    };

    services.godel = {
      infra-ip = infra_ip;
      external-ip = external_ip;
      k3s = {
        enable = true;
        interface = "tailscale0";
        cluster = "public";
        role = "agent";
        region = "lax";
      };
      alloy.enable = true;
      dummy.enable = true;
      tailscale = {
        enable = true;
      };
    };
  };
}
