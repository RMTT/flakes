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
      extra_routes = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
    };
  };

  config = mkIf cfg.enable {
    networking.useNetworkd = true;

    systemd.network.netdevs."godel" = {
      netdevConfig = {
        Kind = "dummy";
        Name = "godel";
      };
    };
    systemd.network.networks."godel" = {
      matchConfig.Name = "godel";
      address = [ "${cfg.ip}/32" ];
    };

    services.tailscale = {
      enable = true;
      openFirewall = true;
      useRoutingFeatures = "both";
      extraSetFlags = [
        "--advertise-routes=${concatStringsSep "," ([ "${cfg.ip}/32" ] ++ cfg.extra_routes)}"
        "--relay-server-port=40000"
        "--accept-routes=true"
        "--snat-subnet-routes=false"
      ];
    };
    networking.firewall.allowedUDPPorts = [
      40000
    ];
  };
}
