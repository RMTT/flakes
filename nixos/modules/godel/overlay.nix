{ config, lib, ... }:
with lib;
let
  cfg = config.services.godel.overlay;
in
{
  options = {
    services.godel.overlay = {
      enable = mkEnableOption "enable godel service";
      ip = mkOption {
        type = types.str;
      };
      extra_args = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
      connect_via = mkOption {
        type = types.str;
        default = "tcp";
      };
      extra_routes = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
    };
  };

  config = mkIf cfg.enable {
    networking.useNetworkd = true;

    # -- tailscale
    # systemd.network.netdevs."godel" = {
    #   netdevConfig = {
    #     Kind = "dummy";
    #     Name = "godel";
    #   };
    # };
    # systemd.network.networks."godel" = {
    #   matchConfig.Name = "godel";
    #   address = [ "${cfg.ip}/32" ];
    # };
    #
    # sops.secrets.ts-authkey = {
    #   mode = "0400";
    #   sopsFile = ./ts-authkey;
    #   format = "binary";
    # };
    # services.tailscale = {
    #   enable = true;
    #   openFirewall = true;
    #   useRoutingFeatures = "both";
    #   authKeyFile = config.sops.secrets.ts-authkey.path;
    #   extraSetFlags = [
    #     "--advertise-routes=${concatStringsSep "," ([ "${cfg.ip}/32" ] ++ cfg.extra_routes)}"
    #     "--relay-server-port=40000"
    #     "--accept-routes=true"
    #     "--snat-subnet-routes=false"
    #   ];
    # };
    # networking.firewall.allowedUDPPorts = [
    #   40000
    # ];

    # easytier
    sops.secrets.easytier = {
      mode = "0400";
      sopsFile = ./easytier_env;
      format = "binary";
    };
    networking.firewall.allowedUDPPorts = [ 11010 ];
    networking.firewall.allowedTCPPorts = [ 11010 ];
    networking.firewall.trustedInterfaces = [ "godel" ];

    services.easytier = {
      enable = true;
      instances.godel = {
        extraArgs = [
          "--private-mode=true"
          "--proxy-networks=${lib.concatStringsSep "," cfg.extra_routes}"
          "--dev-name=godel"
          "--latency-first"
        ]
        ++ cfg.extra_args;
        environmentFiles = [ config.sops.secrets.easytier.path ];
        settings = {
          ipv4 = "${cfg.ip}";
          listeners = [
            "tcp://0.0.0.0:11010"
            "udp://0.0.0.0:11010"
          ];
          peers = [ "${cfg.connect_via}://cn2-box.rmtt.host:11010" ];
        };
      };
    };
  };
}
