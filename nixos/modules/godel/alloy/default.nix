{ config, lib, ... }:
with lib;
let
  cfg = config.services.godel.alloy;
  godelCfg = config.services.godel;
in
{
  options.services.godel.alloy = {
    enable = mkEnableOption "Prometheus server";
  };

  config = mkIf cfg.enable {
    sops.secrets.alloy-env = {
      sopsFile = ./env;
      format = "binary";
    };
    sops.secrets.alloy-k3s-token = {
      sopsFile = ./k3s-token;
      mode = "0444";
      format = "binary";
    };

    services.alloy = {
      enable = true;
      environmentFile = config.sops.secrets.alloy-env.path;
    };

    environment.etc."alloy/k3s-token".source = config.sops.secrets.alloy-k3s-token.path;
    environment.etc."alloy/config.alloy".text = ''
      // endpoints
      prometheus.remote_write "metrics_service" {
        endpoint {
          url = sys.env("GCLOUD_HOSTED_METRICS_URL")
          basic_auth {
            username = sys.env("GCLOUD_HOSTED_METRICS_ID")
            password = sys.env("GCLOUD_RW_API_KEY")
          }
        }
      }

      loki.write "grafana_cloud_loki" {
          endpoint {
              url = sys.env("GCLOUD_HOSTED_LOGS_URL")
              basic_auth {
                  username = sys.env("GCLOUD_HOSTED_LOGS_ID")
                  password = sys.env("GCLOUD_RW_API_KEY")
              }
          }
      }


      // import other configs
      import.file "node_exporter" {
        filename = "/etc/alloy/node-exporter.alloy"
      }

      ${
        if (godelCfg.k3s.role == "server") then
          ''
            import.file "k8s_monitor" {
              filename = "/etc/alloy/k8s-monitor.alloy"
            }
          ''
        else
          ""
      }
    '';
    environment.etc."alloy/node-exporter.alloy".source = ./node-exporter.alloy;
    environment.etc."alloy/k8s-monitor.alloy".source = ./k8s-monitor.alloy;
  };
}
