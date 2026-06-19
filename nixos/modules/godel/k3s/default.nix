{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.godel.k3s;
  godelCfg = config.services.godel;
in
{
  options = {
    services.godel.k3s = {
      enable = mkEnableOption "enable k3s";
      role = mkOption { type = types.str; };
      interface = mkOption { type = types.str; };
      node-labels = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
    };

  };

  config =
    let
      k3s-config =
        if (cfg.role == "agent") then
          {
            server = "https://k3s-master.infra.rmtt.host:6443";
            node-label = cfg.node-labels;
          }
        else
          {
            cluster-cidr = "10.42.0.0/16";
            service-cidr = "10.43.0.0/16";
            write-kubeconfig-mode = "0644";
            tls-san = [
              "k3s-master.infra.rmtt.host"
            ];
            node-label = cfg.node-labels;
            cluster-init = true;
            flannel-backend = "vxlan";
            flannel-external-ip = true;

            etcd-s3 = true;
            etcd-s3-endpoint = "s3.us-east-005.backblazeb2.com";
            etcd-s3-bucket = "mts-k3s-etcd-backup";
            etcd-s3-insecure = false;
            etcd-s3-retention = "15";
            etcd-snapshot-schedule-cron = "0 * * * *"; # every hour
          };

      yaml = pkgs.formats.yaml { };
    in
    mkIf cfg.enable {
      sops.secrets.k3s-token = {
        mode = "0400";
        sopsFile = ./k3s-token;
        format = "binary";
      };
      sops.secrets.k3s-env = {
        mode = "0400";
        sopsFile = ./k3s-env;
        format = "binary";
      };
      sops.secrets.flux-age = {
        mode = "0400";
        sopsFile = ./flux-age;
        format = "binary";
      };

      networking.firewall.allowedTCPPorts = [ 6443 ];
      networking.firewall.allowedUDPPorts = [ 8472 ];
      services.k3s = {
        enable = true;
        configPath = (yaml.generate "k3s-config" k3s-config);
        environmentFile = config.sops.secrets.k3s-env.path;
        manifests = mkIf (cfg.role == "server") {
          flux-age.source = config.sops.secrets.flux-age.path;
        };
        role = cfg.role;
        extraFlags =
          (
            if (cfg.role == "server") then
              [
                "--disable servicelb"
                "--disable traefik"
                "--supervisor-metrics"
              ]
            else
              [ ]
          )
          ++ [
            "--token-file ${config.sops.secrets.k3s-token.path}"
            "--node-ip ${godelCfg.infra-ip}"
            "--node-external-ip ${godelCfg.infra-ip}"
            "--kube-proxy-arg 'nodeport-addresses=${godelCfg.infra-ip}/24'"
            "--flannel-iface ${cfg.interface}"
          ];
      };
      networking.firewall.trustedIpv4 = [
        # need pass pod id to let pod access api server which listend on the node-ip
        "10.42.0.0/16" # pod ip range
      ];
    };
}
