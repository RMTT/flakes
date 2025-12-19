{ lib, config, ... }:
with lib;
let
  cfg = config.machine.networking.firewall;
in
{
  options.machine.networking.firewall.preset = mkOption {
    type = types.bool;
    default = true;
  };

  config = mkIf cfg.preset {
    networking.firewall = {
      trustedIpv4 = [
        "192.168.6.1/24" # local net of home
        "100.64.0.0/10" # tailscale
      ];
      trustedIpv6 = [
        "fd7a:115c:a1e0::/48" # tailscale
      ];

      allowedUDPPorts = [
        68 # DHCP
        67 # DHCP
        5201 # for iperf
        53 # for dns
      ];
      allowedTCPPorts = [
        5201 # for iperf
      ];
    };

  };
}
