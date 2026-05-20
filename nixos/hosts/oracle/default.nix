{
  pkgs,
  lib,
  config,
  modulesPath,
  ...
}:
let
  infra_ip = "198.19.20.1";
in
{
  imports = [
    (modulesPath + "/virtualisation/oci-common.nix")
    ./secrets
  ];

  config = {
    oci.efi = true;
    machine.graphics.enable = false;
    machine.bootloader.enable = false;
    system.stateVersion = "26.05";
    nixpkgs.hostPlatform = "aarch64-linux";

    boot.kernelParams = [ "net.ifnames=0" ];

    services.vnstat.enable = true;

    services.godel = {
      infra-ip = infra_ip;
      overlay.enable = false;
      prometheus.server.enable = true;
      prometheus.node-exporter.enable = true;
      grafana.enable = true;
      wireguard = {
        enable = true;
        privateKeyFile = config.sops.secrets.godel-wg.path;
      };
      k3s = {
        enable = true;
        interface = "godel";
        role = "agent";
      };
      traefik = {
        enable = true;
        configFile = ./secrets/traefik-dynamic.toml;
        envFile = config.sops.secrets.traefik-env.path;
      };
      uptime = {
        enable = true;
      };
    };

    services.cloudflare-tunnel = {
      enable = true;
      tokenFile = config.sops.secrets.tunnel.path;
    };

    services.cellerd = {
      enable = true;
      environmentFile = "${config.sops.secrets.celler-env.path}";
      settings = {
        listen = "[::]:8100";
        chunking = {
          nar-size-threshold = 131072;
          min-size = 65536;
          avg-size = 131072;
          max-size = 262144;
        };
      };
    };
  };
}
