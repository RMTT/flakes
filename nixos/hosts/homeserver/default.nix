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
    ./disko.nix
    ./secrets
  ];

  config =
    let
      infra_node_ip = "198.19.19.2";
      wan_interface = "enp2s0";
    in
    {
      system.stateVersion = "25.11";

      nixpkgs.hostPlatform = "x86_64-linux";
      networking.useDHCP = false;
      machine.graphics.enable = false;
      services.qemuGuest.enable = true;
      machine.bootloader.systemd-boot.enable = true;
      machine.users.mt.hashedPassword = "$y$j9T$wd.PhKRHTbfe0WFQ4iqPv0$CMH7Ry3d7lcZJvF3N.o7x9EtoR7P6FCp6wq9JHAnvp2";
      zramSwap = {
        enable = true;
        memoryPercent = 20;
      };

      systemd.network.networks.wan = {
        matchConfig.Name = wan_interface;
        address = [ "${infra_node_ip}/24" ];
        gateway = [ "198.19.19.1" ];
        dns = [ "1.1.1.1" ];
      };
      services.restic.backups = {
        k3s = {
          paths = [ "/var/lib/rancher/k3s" ];
          exclude = [ "/var/lib/rancher/k3s/data" ];
          initialize = true;
          passwordFile = config.sops.secrets.restic-pass.path;
          repositoryFile = config.sops.secrets.restic-repo.path;
          timerConfig = {
            OnCalendar = "*-*-* 00/4:00:00";
            Persistent = true;
          };
        };
      };
      services.godel = {
        infra-ip = infra_node_ip;
        prometheus.node-exporter.enable = true;
        k3s = {
          enable = true;
          role = "agent";
          interface = wan_interface;
        };
        traefik = {
          enable = true;
          configFile = ./secrets/traefik-dynamic.toml;
          envFile = config.sops.secrets.traefik-env.path;
        };
      };
    };
}
