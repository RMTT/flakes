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

    blackbox-exporter = {
      enable = mkEnableOption "Prometheus blackbox exporter";
    };
  };

  config = mkMerge [
    (mkIf cfg.server.enable {
      services.prometheus = {
        enable = true;
        listenAddress = "${godelCfg.infra-ip}";
        port = 9090;
        retentionTime = "60d";
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
            job_name = "blackbox_http";
            scrape_interval = "3m";
            metrics_path = "/probe";
            params.module = [ "http_2xx" ];
            static_configs = [
              {
                targets = [
                  "https://grafana.rmtt.tech"
                ];
              }
            ];
            relabel_configs = [
              {
                source_labels = [ "__address__" ];
                target_label = "__param_target";
              }
              {
                source_labels = [ "__param_target" ];
                target_label = "instance";
              }
              {
                target_label = "__address__";
                replacement = "${godelCfg.infra-ip}:9115";
              }
            ];
          }
          {
            job_name = "blackbox_icmp";
            scrape_interval = "3m";
            metrics_path = "/probe";
            params.module = [ "icmp" ];
            static_configs = [
              {
                targets = [
                  "oracle.infra.rmtt.host"
                  "kube-runner.infra.rmtt.host"
                ];
              }
            ];
            relabel_configs = [
              {
                source_labels = [ "__address__" ];
                target_label = "__param_target";
              }
              {
                source_labels = [ "__param_target" ];
                target_label = "instance";
              }
              {
                target_label = "__address__";
                replacement = "${godelCfg.infra-ip}:9115";
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
