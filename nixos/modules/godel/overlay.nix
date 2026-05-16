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
      extraRoutes = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
    };
  };

  config = mkIf cfg.enable {
    services.tailscale =
      let
        routes = [ "${godelCfg.infra-ip}/32" ] ++ cfg.extraRoutes;
      in
      {
        enable = true;
        openFirewall = true;
        useRoutingFeatures = "both";
        extraSetFlags = [
          "--accept-routes"
          "--advertise-routes=${lib.concatStringsSep "," routes}"
        ];
      };
  };
}
