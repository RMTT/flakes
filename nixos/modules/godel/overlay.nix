{ config, lib, ... }:
with lib;
let
  cfg = config.services.godel.overlay;
  port = 41821;
  tunnelPort = 41900;
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
      tunnel = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  config = mkIf cfg.enable {
    sops.secrets.godel-pass = {
      sopsFile = ./pass;
      format = "binary";
    };
    services.udp2raw = mkIf cfg.tunnel {
      enable = true;
      role = cfg.mode;
      localAddress = "0.0.0.0";
      localPort = if (cfg.mode == "server") then tunnelPort else port;
      remoteAddress = if (cfg.mode == "server") then "127.0.0.1" else "104.194.71.122";
      remotePort = if (cfg.mode == "server") then port else tunnelPort;
      passwordFile = config.sops.secrets.godel-pass.path;
    };
    networking.wg-quick.interfaces.godel = {
      privateKeyFile = config.sops.secrets.godel.path;
      mtu = 1300;
      address = [ "${cfg.ip}/32" ];
      listenPort = mkIf (cfg.mode == "server") port;

      peers =
        (import ./registry.nix {
          port = port;
          tunnel = cfg.tunnel;
        })."${cfg.mode}";
    };

    networking.firewall.allowedUDPPorts = mkIf (cfg.mode == "server") [
      config.networking.wg-quick.interfaces.godel.listenPort
    ];
    networking.firewall.allowedTCPPorts = mkIf (cfg.mode == "server") [ tunnelPort ];
    networking.firewall.trustedInterfaces = [ "godel" ];
  };
}
