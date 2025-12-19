{ config, lib, ... }:
with lib;
let
  cfg = config.services.godel;
in
{
  options = {
    services.godel = {
      enable = mkEnableOption "enable godel service";
      extra_routes = mkOption {
        type = types.str;
        default = "";
      };
    };
  };

  config = mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      openFirewall = true;
      interfaceName = "godel";
      authKeyFile = config.sops.secrets.godel.path;
      useRoutingFeatures = "both";
      extraSetFlags = [
        "--advertise-routes=${cfg.extra_routes}"
        "--relay-server-port=40000"
        "--accept-routes=true"
        "--snat-subnet-routes=false"
      ];
    };
    # for peer relay
    networking.firewall.allowedUDPPorts = [
      40000
      3478
    ];
  };
}
