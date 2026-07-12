{
  pkgs,
  lib,
  config,
  modulesPath,
  ...
}:
let
  infra_ip = "198.19.20.1";
  external_ip = "147.224.201.181";
in
{
  imports = [
    (modulesPath + "/virtualisation/oci-common.nix")
    ./secrets
  ];

  config = {
    oci.efi = true;
    machine.graphics.enable = false;
    machine.users.mt.hashedPassword = "$y$j9T$3ODPssSOIWrWgJA15q8P1.$eUp2hFhQ4D6Gujz8twXsb3NFNoRB/OkGh5FSKTuOFA5";
    system.stateVersion = "26.05";
    nixpkgs.hostPlatform = "aarch64-linux";

    boot.kernelParams = [ "net.ifnames=0" ];

    services.vnstat.enable = true;

    services.restic.backups = {
      k3s = {
        paths = [ "/var/lib/rancher/k3s" ];
        exclude = [ "/var/lib/rancher/k3s/data" ];
        initialize = true;
        passwordFile = config.sops.secrets.restic-pass.path;
        repositoryFile = config.sops.secrets.restic-repo.path;
        environmentFile = config.sops.secrets.restic-env.path;
        timerConfig = {
          OnCalendar = "*-*-* 00/4:00:00";
          Persistent = true;
        };
        pruneOpts = [
          "--keep-daily 7"
          "--keep-last 7"
        ];
      };
    };
    services.fail2ban.enable = true;
    services.godel = {
      infra-ip = infra_ip;
      external-ip = external_ip;
      alloy.enable = true;
      k3s = {
        enable = true;
        cluster = "public";
        role = "server";
        region = "oracle";
      };
      tailscale = {
        enable = true;
      };
      wireguard = {
        enable = true;
        privateKeyFile = config.sops.secrets.godel-wg.path;
      };
      dns.enable = true;
    };

    services.cloudflare-tunnel = {
      enable = true;
      tokenFile = config.sops.secrets.tunnel.path;
    };
  };
}
