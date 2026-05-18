{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.godel.grafana;
  godelCfg = config.services.godel;
in
{
  options.services.godel.grafana = {
    enable = mkEnableOption "Grafana";
  };

  config = mkIf cfg.enable {
    services.grafana = {
      enable = true;
      settings = {
        security.secret_key = "$__file{${config.sops.secrets.grafana-secret.path}}";
        security.admin_email = "iamrmttt@gmail.com";
        panels.disable_sanitize_html = true;
        server = {
          domain = "grafana.rmtt.tech";
          root_url = "https://grafana.rmtt.tech";
          http_addr = "${godelCfg.infra-ip}";
          http_port = 3000;
        };
      };

      provision = {
        enable = true;
        dashboards.settings.providers = [
          {
            name = "Homepage";
            options.path = "${import ./homepage.nix pkgs}";
          }
          {
            name = "Nodes";
            options.path = "${import ./node-exporter-full.nix pkgs}";
          }
          {
            name = "Kubernetes";
            options.path = "${./kubernetes.json}";
          }
        ];
        datasources.settings.datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            access = "proxy";
            url = "http://${godelCfg.infra-ip}:9090";
            isDefault = true;
          }
        ];
      };
    };
  };
}
