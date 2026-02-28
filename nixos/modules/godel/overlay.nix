{ config, lib, ... }:
with lib;
let
  cfg = config.services.godel.overlay;
  registry = import ./registry.nix;
in
{
  options = {
    services.godel.overlay = {
      enable = mkEnableOption "enable godel service";
      ip = mkOption {
        type = types.str;
      };
      mode = mkOption {
        type = types.str;
        default = "client";
      };
    };
  };

  config = mkIf cfg.enable {
    networking.useNetworkd = true;

    networking.wireguard.interfaces.godel = {
      privateKeyFile = config.sops.secrets.godel.path;
      mtu = 1300;
      ips = [ "${cfg.ip}/32" ];
      listenPort = 41820;

      peers = registry."${cfg.mode}";
    };

    networking.firewall.allowedUDPPorts = [ config.networking.wireguard.interfaces.godel.listenPort ];
    networking.firewall.trustedInterfaces = [ "godel" ];
  };
}
