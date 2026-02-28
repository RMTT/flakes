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
        18080
      ];

      services.ssserver = {
        enable = true;
        port = 48388;
        method = "2022-blake3-aes-256-gcm";
        openFirewall = true;
        passwordFile = config.sops.secrets.ss.path;
      };
      services.godel = {
        overlay = {
          enable = true;
          ip = infra_node_ip;
          mode = "server";
        };
        k3s = {
          enable = true;
          node-ip = infra_node_ip;
          role = "agent";
        };
      };
    };
}
