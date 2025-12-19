{
  pkgs,
  lib,
  config,
  modulesPath,
  ...
}:
{
  imports = [
    ./disk-config.nix
    (modulesPath + "/profiles/qemu-guest.nix")
    ./secrets
  ];

  config =
    let
      infra_node_ip = "100.100.128.3";
      wan = "enp1s0";
    in
    {
      system.stateVersion = "24.11";

      hardware.cpu.intel.updateMicrocode = true;
      networking.useNetworkd = true;

      machine.graphics.enable = false;
      boot.loader.systemd-boot.enable = lib.mkForce false;
      boot.loader.grub.enable = lib.mkForce true;
      boot.loader.efi.canTouchEfiVariables = lib.mkForce false;

      services.godel = {
        enable = true;
        extra_routes = "10.42.3.0/24";
        k3s = {
          enable = true;
          node-ip = infra_node_ip;
          role = "agent";
        };
      };

      services.prometheus = {
        globalConfig.scrape_interval = "1m";
        enable = true;
        scrapeConfigs = [
          {
            job_name = "prometheus";
            static_configs = [
              {
                targets = [
                  "de-hz.infra.rmtt.host:${toString config.services.prometheus.port}"
                ];
              }
            ];
          }
          {
            job_name = "node";
            static_configs = [
              {
                targets = [
                  "de-hz.infra.rmtt.host:${toString config.services.prometheus.exporters.node.port}"

                  "homeserver.infra.rmtt.host:${toString config.services.prometheus.exporters.node.port}"

                  "cn2-box.infra.rmtt.host:${toString config.services.prometheus.exporters.node.port}"
                ];
              }
            ];
          }
          {
            job_name = "smartctl";
            static_configs = [
              {
                targets = [
                  "homeserver.infra.rmtt.host:${toString config.services.prometheus.exporters.smartctl.port}"
                ];
              }
            ];
          }
        ];

        remoteWrite = [
          {
            url = "https://prometheus-prod-49-prod-ap-northeast-0.grafana.net/api/prom/push";
            basic_auth = {
              username = "2319367";
              password_file = config.sops.secrets.grafana-token.path;
            };
          }
        ];

        exporters.node.enable = true;
      };
    };
}
