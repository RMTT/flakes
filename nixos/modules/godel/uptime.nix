{ config, lib, ... }:
with lib;
let
  cfg = config.services.godel.uptime;
  godelCfg = config.services.godel;
in
{
  options = {
    services.godel.uptime = {
      enable = mkEnableOption "enable uptime";
    };
  };

  config = mkIf cfg.enable {
    services.gatus = {
      enable = true;
      settings = {
        web = {
          port = 8090;
          address = "${godelCfg.infra-ip}";
        };
        storage = {
          type = "sqlite";
          path = "/var/lib/gatus/data.db";
        };
        ui = {
          title = "Homelab Status";
          header = "RMT's Homelab";
          logo = "https://avatars.githubusercontent.com/u/20596599";
          link = "https://status.rmtt.tech";
          default-sort-by = "group";
        };
        endpoints = [
          {
            name = "Oracle";
            group = "infra connectivity";
            url = "icmp://oracle.infra.rmtt.host";
            interval = "3m";
            conditions = [
              "[CONNECTED] == true"
            ];
          }
          {
            name = "Homerouter";
            group = "infra connectivity";
            url = "icmp://homerouter.infra.rmtt.host";
            interval = "3m";
            conditions = [
              "[CONNECTED] == true"
            ];
          }
          {
            name = "Homeserver";
            group = "infra connectivity";
            url = "icmp://homeserver.infra.rmtt.host";
            interval = "3m";
            conditions = [
              "[CONNECTED] == true"
            ];
          }
          {
            name = "TrueNAS";
            group = "infra connectivity";
            url = "icmp://nas.infra.rmtt.host";
            interval = "3m";
            conditions = [
              "[CONNECTED] == true"
            ];
          }

          {
            name = "Grafana";
            group = "services";
            url = "https://grafana.rmtt.tech";
            interval = "3m";
            conditions = [
              "[STATUS] == 200"
            ];
          }
        ];
      };
    };
  };
}
