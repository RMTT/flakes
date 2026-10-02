{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.godel.tailscale;
  godelCfg = config.services.godel;
in
{
  options = {
    services.godel.tailscale = {
      enable = lib.mkEnableOption "enable godel service";
      extraRoutes = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };
    };
  };

  config = lib.mkIf cfg.enable {
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
