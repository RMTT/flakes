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
      interface = mkOption {
        type = types.str;
        default = "godel";
      };
      region = mkOption {
        type = types.str;
      };
      cluster = mkOption {
        type = types.enum [
          "homelab"
          "public"
        ];
      };
    };

  };

  config =
    let
      serverUrl = if (cfg.cluster == "public") then "https://k3s-master.infra.rmtt.host:6443" else "";
      k3s-config = {
        node-label = [ "topology.kubernetes.io/region=${cfg.region}" ];
        token-file = "${config.sops.secrets.k3s-token.path}";
        node-ip = godelCfg.infra-ip;
        kube-proxy-arg = [ "nodeport-addresses=${godelCfg.infra-ip}/24" ];
      }
      // optionalAttrs (godelCfg.external-ip != null) {
        node-external-ip = godelCfg.external-ip;
      }
      // optionalAttrs (cfg.role == "agent") {
        server = serverUrl;
      }
      // optionalAttrs (cfg.role == "server") {
        flannel-backend = "wireguard-native";
        flannel-external-ip = true;
        # always use node-ip as api server address
        advertise-address = godelCfg.infra-ip;
        cluster-init = true;
        supervisor-metrics = true;
        cluster-cidr = "10.42.0.0/16";
        service-cidr = "10.43.0.0/16";
        service-node-port-range = "80-32767";
        write-kubeconfig-mode = "0644";
        tls-san = [
          serverUrl
        ];

        disable = [
          "servicelb"
          "traefik"
        ];

        etcd-s3 = true;
        etcd-s3-endpoint = "s3.us-east-005.backblazeb2.com";
        etcd-s3-bucket = "mts-k3s-etcd-backup";
        etcd-s3-folder = cfg.cluster;
        etcd-s3-insecure = false;
        etcd-s3-retention = "15";
        etcd-snapshot-schedule-cron = "0 * * * *"; # every hour
      };

      yaml = pkgs.formats.yaml { };
    in
    mkIf cfg.enable {
      sops.secrets.k3s-token = {
        mode = "0400";
        sopsFile = ./secrets/k3s-token;
        format = "binary";
      };
      sops.secrets.k3s-env = {
        mode = "0400";
        sopsFile = ./secrets/k3s-env;
        format = "binary";
      };
      sops.secrets.flux-age = {
        mode = "0400";
        sopsFile = ./secrets/flux-age;
        format = "binary";
      };

      environment.systemPackages = [ pkgs.juicefs ];

      services.k3s = {
        enable = true;
        configPath = (yaml.generate "k3s-config" k3s-config);
        environmentFile = config.sops.secrets.k3s-env.path;
        manifests = mkIf (cfg.role == "server") {
          flux-age.source = config.sops.secrets.flux-age.path;
        };
        role = cfg.role;
      };

      networking.firewall.allowedUDPPorts = [ 51820 ]; # for wireguard-native
      networking.firewall.trustedIpv4 = [
        # need pass pod id to let pod access api server which listend on the node-ip
        "10.42.0.0/16" # pod ip range
      ];
    };
}
