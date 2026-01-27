{ config, lib, ... }:
with lib;
let
  cfg = config.services.godel.dummy;
in
{
  options = {
    services.godel.dummy = {
      enable = mkEnableOption "enable godel service";
      ip = mkOption {
        type = types.str;
      };
    };
  };

  config = mkIf cfg.enable {
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
  };
}
