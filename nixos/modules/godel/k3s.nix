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
            server = "https://kube-runner.infra.rmtt.host:6443";
            node-label = cfg.node-labels;
          }
        else
          {
            cluster-cidr = "10.42.0.0/16";
            service-cidr = "10.43.0.0/16";
            write-kubeconfig-mode = "0644";
            tls-san = [
              "kube-runner.infra.rmtt.host"
              "kube-runner.home.rmtt.host"
            ];
            node-label = cfg.node-labels;
            cluster-init = true;
            flannel-backend = "vxlan";
            flannel-external-ip = true;
          };

      yaml = pkgs.formats.yaml { };
    in
    mkIf cfg.enable {
      sops.secrets.k3s-token = {
        mode = "0400";
        sopsFile = ./k3s-token;
        format = "binary";
      };

      networking.firewall.allowedTCPPorts = [ 6443 ];
      networking.firewall.allowedUDPPorts = [ 8472 ];
      services.k3s = {
        enable = true;
        configPath = (yaml.generate "k3s-config" k3s-config);
        role = cfg.role;
        manifests = {
          traefik-custom.source = ./traefik-custom.yaml;
        };
        extraFlags =
          (
            if (cfg.role == "agent") then
              [ "--token-file ${config.sops.secrets.k3s-token.path}" ]
            else
              [ "--disable servicelb" ]
          )
          ++ [
            "--node-ip ${godelCfg.infra-ip}"
            "--node-external-ip ${godelCfg.infra-ip}"
            "--kube-proxy-arg 'nodeport-addresses=${godelCfg.infra-ip}/24'"
            "--kube-proxy-arg 'proxy-mode=nftables'"
            "--flannel-iface ${cfg.interface}"
          ];
      };

      systemd.services.k3s.path = with pkgs; [ nftables ];
      networking.firewall.trustedIpv4 = [
        # need pass pod id to let pod access api server which listend on the node-ip
        "10.42.0.0/16" # pod ip range
      ];
    };
}
