{ config, lib, ... }:
with lib;
let
  cfg = config.services.godel.prometheus;
  godelCfg = config.services.godel;
in
{
  options.services.godel.prometheus = {
    server = {
      enable = mkEnableOption "Prometheus server";
    };

    node-exporter = {
      enable = mkEnableOption "Prometheus node exporter";
    };
  };

  config = mkMerge [
    (mkIf cfg.server.enable {
      sops.secrets.prometheus-k3s-token = {
        sopsFile = ./k3s-token;
        format = "binary";
        owner = "prometheus";
      };

      services.prometheus = {
        enable = true;
        listenAddress = "${godelCfg.infra-ip}";
        port = 9090;
        retentionTime = "60d";
        checkConfig = "syntax-only";
        extraFlags = [
          "--storage.tsdb.wal-compression"
          "--storage.tsdb.retention.size=50GB"
        ];
        scrapeConfigs = [
          {
            job_name = "Nodes";
            scrape_interval = "1m";
            static_configs = [
              {
                targets = [
                  "oracle.infra.rmtt.host:9100"
                  "homeserver.infra.rmtt.host:9100"
                ];
              }
            ];
          }
          {
            job_name = "kubernetes-cadvisor";
            scheme = "https";
            scrape_interval = "1m";
            metrics_path = "/metrics/cadvisor";
            kubernetes_sd_configs = [
              {
                role = "node";
                api_server = "https://k3s-master.infra.rmtt.host:6443";
                tls_config.insecure_skip_verify = true;
                authorization.credentials_file = "${config.sops.secrets.prometheus-k3s-token.path}";
              }
            ];
            tls_config.insecure_skip_verify = true;
            bearer_token_file = "${config.sops.secrets.prometheus-k3s-token.path}";
          }
          {
            job_name = "kubernetes-resources";
            scheme = "https";
            scrape_interval = "1m";
            metrics_path = "/metrics/resource";
            kubernetes_sd_configs = [
              {
                role = "node";
                api_server = "https://k3s-master.infra.rmtt.host:6443";
                tls_config.insecure_skip_verify = true;
                authorization.credentials_file = "${config.sops.secrets.prometheus-k3s-token.path}";
              }
            ];
            tls_config.insecure_skip_verify = true;
            bearer_token_file = "${config.sops.secrets.prometheus-k3s-token.path}";
          }
          {
            job_name = "kubernetes-nodes";
            scheme = "https";
            scrape_interval = "1m";
            metrics_path = "/metrics";
            kubernetes_sd_configs = [
              {
                role = "node";
                api_server = "https://k3s-master.infra.rmtt.host:6443";
                tls_config.insecure_skip_verify = true;
                authorization.credentials_file = "${config.sops.secrets.prometheus-k3s-token.path}";
              }
            ];
            tls_config.insecure_skip_verify = true;
            bearer_token_file = "${config.sops.secrets.prometheus-k3s-token.path}";
          }
        ];
      };
    })

    (mkIf cfg.node-exporter.enable {
      services.prometheus.exporters.node = {
        enable = true;
        listenAddress = "${godelCfg.infra-ip}";
        port = 9100;
      };
    })
  ];
}
