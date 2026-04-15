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
            port = 8080;
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
              name = "cn2-box connectivity";
              group = "infra connectivity";
              url = "icmp://198.19.198.3";
              interval = "3m";
              conditions = [
                "[CONNECTED] == true"
              ];
            }
            {
              name = "labrouter connectivity";
              group = "infra connectivity";
              url = "icmp://198.19.19.1";
              interval = "3m";
              conditions = [
                "[CONNECTED] == true"
              ];
            }
          ];
        };
      };
  };
}
