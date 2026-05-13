{
  pkgs,
  lib,
  config,
  modulesPath,
  ...
}:
with lib;
{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
    ./secrets
    ./homepage.nix
  ];

  config = {
    system.stateVersion = "26.05";
    documentation.enable = false;
    documentation.nixos.enable = false;

    networking.useNetworkd = true;
    boot.loader.systemd-boot.enable = mkForce false;
    machine.graphics.enable = false;
    nixpkgs.hostPlatform = "x86_64-linux";
    nix.settings = {
      sandbox = false;
    };
    proxmoxLXC.manageNetwork = true;
    networking.useHostResolvConf = false;
    services.fstrim.enable = false;
    # have to suppress these units, since they do not work inside LXC
    systemd.suppressedSystemUnits = [
      "sys-kernel-debug.mount"
    ];

    environment.systemPackages = with pkgs; [ kmod ];

    services.traefik = {
      enable = true;
      staticConfigOptions = {
        api = {
          dashboard = true;
          insecure = true;
        };
        entryPoints = {
          web = {
            address = ":80";
          };
          websecure = {
            address = ":443";
          };
        };
        certificatesResolvers.dnsresolver.acme = {
          email = "iamrmttt@gmail.com";
          dnsChallenge = {
            provider = "cloudflare";
            delayBeforeCheck = 60;
            resolvers = [
              "223.5.5.5:53"
              "8.8.8.8:53"
            ];
          };
        };
      };
      environmentFiles = [ config.sops.secrets.traefik-env.path ];
      dynamicConfigFile = ./secrets/traefik-dynamic.toml;
    };

  };
}
