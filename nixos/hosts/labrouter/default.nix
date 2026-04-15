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
  ];

  config = {
    system.stateVersion = "26.05";

    networking.useNetworkd = true;
    boot.loader.systemd-boot.enable = mkForce false;
    machine.graphics.enable = false;
    nix.settings = {
      sandbox = false;
    };
    proxmoxLXC.privileged = true;
    proxmoxLXC.manageNetwork = true;
    networking.useHostResolvConf = false;
    services.fstrim.enable = false; # Let Proxmox host handle fstrim
    # have to suppress these units, since they do not work inside LXC
    systemd.suppressedSystemUnits = [
      "sys-kernel-debug.mount"
    ];

    environment.systemPackages = with pkgs; [ kmod ];

    services.godel = {
      overlay.enable = true;
      hostsRecord.enable = true;
    };

    services.sblite = {
      enable = true;
      listenAddress = "198.19.19.1:8180";
    };
    networking.firewall.trustedInterfaces = [ "sing-box" ];

    services.resolved.enable = mkForce false;
    services.dnsmasq = {
      enable = true;
      resolveLocalQueries = true;
      settings = {
        listen-address = [
          "127.0.0.1"
          "::"
        ];
        interface = [ "eth0" ];
        local = [
          "/rmtt.tech/"
          "/rmtt.fun/"
          "/home.rmtt.host/"
          "/infra.rmtt.host/"
        ];
        local-service = false;
        no-dhcp-interface = "*";
        no-resolv = true;
        no-hosts = false;
        log-queries = true;
        bogus-priv = true;
        server = [
          "1.1.1.1"
          "8.8.8.8"
        ];
      };
    };

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
