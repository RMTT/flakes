{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.machine.networking;
in
{
  imports = [ ./firewall.nix ];
  options = {
    machine.networking = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
      useNetworkd = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.iproute2.enable = true;
    networking.nftables.enable = true;
    networking.useNetworkd = cfg.useNetworkd;
    systemd.network = lib.mkIf cfg.useNetworkd {
      wait-online.anyInterface = true;
    };

    boot.kernel.sysctl = {
      "net.ipv4.conf.all.forwarding" = true;
      "net.ipv6.conf.all.forwarding" = lib.mkDefault 1;
      "net.ipv4.conf.all.route_localnet" = lib.mkDefault 1;
    };

    networking.networkmanager = lib.mkIf (!cfg.useNetworkd) {
      enable = true;
      dns = "systemd-resolved";
    };
    services.resolved.enable = true;
  };
}
