{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.machine.networking;
in
with lib;
{
  imports = [ ./firewall.nix ];
  options = {
    machine.networking = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };

  config = mkIf cfg.enable {
    networking.iproute2.enable = true;
    networking.nftables.enable = true;
    systemd.network = mkIf config.networking.useNetworkd {
      wait-online.anyInterface = true;
    };

    boot.kernel.sysctl = {
      "net.ipv4.conf.all.forwarding" = true;
      "net.ipv6.conf.all.forwarding" = mkDefault 1;
      "net.ipv4.conf.all.route_localnet" = mkDefault 1;
    };

    networking.networkmanager = mkIf (!config.networking.useNetworkd) {
      enable = true;
      dns = "systemd-resolved";
    };
    services.resolved.enable = true;
  };
}
