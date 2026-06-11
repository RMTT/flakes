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

      nixpkgs.hostPlatform = "x86_64-linux";
      networking.useDHCP = false;
      machine.graphics.enable = false;
      services.qemuGuest.enable = true;
      machine.bootloader.systemd-boot.enable = true;
      machine.users.mt.hashedPassword = lib.mkDefault "$y$j9T$q1VIDTHKt/ShoEFdo.gMc0$RRX0FIaJ4hAVhVtOqXwLHG9xUsxz2h/1Ctr3ownx.27";
      zramSwap = {
        enable = true;
        memoryPercent = 20;
      };

      systemd.network.networks.wan = {
        matchConfig.Name = "ens18";
        address = [ "${infra_node_ip}/24" ];
        gateway = [ "198.19.19.1" ];
        dns = [ "1.1.1.1" ];
      };
      machine.secrets.enable = true;
      services.godel = {
        infra-ip = infra_node_ip;
        prometheus.node-exporter.enable = true;
        k3s = {
          enable = true;
          role = "server";
          interface = "ens18";
        };
        traefik = {
          enable = true;
          configFile = ./secrets/traefik-dynamic.toml;
          envFile = config.sops.secrets.traefik-env.path;
        };
      };
    };
}
