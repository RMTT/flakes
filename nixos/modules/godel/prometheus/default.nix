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
                  "cn2-box.infra.rmtt.host:9100"
                  "kube-runner.infra.rmtt.host:9100"
                  "labrouter.infra.rmtt.host:9100"
                ];
              }
            ];
          }
          {
            job_name = "kubernetes-cadvisor";
            scheme = "https";
            scrape_interval = "1m";
            metrics_path = "/metrics/cadvisor";
            tls_config.insecure_skip_verify = true;
            bearer_token_file = "${config.sops.secrets.prometheus-k3s-token.path}";
            static_configs = [
              {
                targets = [
                  "kube-runner.infra.rmtt.host:10250"
                  "oracle.infra.rmtt.host:10250"
                ];
              }
            ];
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
