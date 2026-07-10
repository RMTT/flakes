{
  pkgs,
  lib,
  config,
  modulesPath,
  ...
}:
let
  infra_ip = "198.19.20.3";
  external_ip = "147.224.143.231";
in
{
  imports = [
    (modulesPath + "/virtualisation/oci-common.nix")
    ./secrets
  ];

  config = {
    oci.efi = true;
    machine.graphics.enable = false;
    machine.users.mt.hashedPassword = "$y$j9T$lzgs19Wd4wTJZrfcu4Zcp0$0cBreYmJqGOMZBYU2KUN5w6l0AiFHEP.uu6FK.fm3T/";
    system.stateVersion = "26.11";
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
        role = "agent";
        region = "oracle";
      };
      tailscale = {
        enable = true;
      };
      dummy.enable = true;
    };
  };
}
