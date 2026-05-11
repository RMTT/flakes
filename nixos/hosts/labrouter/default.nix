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

    networking.interfaces.homelab.ipv4.routes = [
      {
        address = "198.19.19.0";
        prefixLength = 24;
      }
    ];
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
      settings = {
        listen-address = [
          "127.0.0.1"
          "198.19.19.1"
        ];
        local = [
          "/rmtt.tech/"
          "/rmtt.fun/"
          "/home.rmtt.host/"
          "/infra.rmtt.host/"
        ];
        bind-dynamic = true;
        local-service = false;
        no-dhcp-interface = "*";
        no-resolv = true;
        no-hosts = false;
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
