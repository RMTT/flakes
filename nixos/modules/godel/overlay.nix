{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.godel.overlay;
  godelCfg = config.services.godel;
in
{
  options = {
    services.godel.overlay = {
      enable = mkEnableOption "enable godel service";
    };
  };

  config = mkIf cfg.enable {
    systemd.network.netdevs."10-godel" = {
      netdevConfig = {
        Name = "godel";
        Kind = "dummy";
      };
    };
    systemd.network.networks."10-godel" = {
      matchConfig.Name = "godel";
      address = [ "${godelCfg.infra-ip}/32" ];
      networkConfig = {
        LinkLocalAddressing = "no";
      };
    };
    services.tailscale = {
      enable = true;
      openFirewall = true;
      useRoutingFeatures = "both";
    };
  };
}
