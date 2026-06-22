{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.godel.dummy;
  godelCfg = config.services.godel;
in
{
  options = {
    services.godel.dummy = {
      enable = mkEnableOption "enable dummy device for godel";
    };
  };

  config = mkIf cfg.enable {
    systemd.network.netdevs = {
      godel = {
        netdevConfig = {
          Kind = "dummy";
          Name = "godel";
        };
      };
    };

    systemd.network.networks = {
      godel = {
        matchConfig.Name = "godel";
        address = [ "${godelCfg.infra-ip}/32" ];
      };
    };
  };
}
