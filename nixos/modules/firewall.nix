{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.networking.firewall;
in
{
  options = {
    networking.firewall = {
      trustedIpv4 = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
      trustedIpv6 = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };

      extraOutputRules = mkOption {
        type = types.str;
        default = "";
      };
    };
  };

  config =
    let
      subnetsV4 = concatStringsSep "," cfg.trustedIpv4;
      subnetsV6 = concatStringsSep "," cfg.trustedIpv6;
    in
    {
      networking.firewall = {
        enable = true;
        checkReversePath = "loose";
        logRefusedConnections = false;
        logRefusedUnicastsOnly = false;
        extraInputRules = ''
          ${optionalString (subnetsV4 != "") "ip saddr { ${subnetsV4} } accept"}
          ${optionalString (subnetsV6 != "") "ip6 saddr { ${subnetsV6} } accept"}
        '';
      };

      networking.nftables.tables = {
        mynixos-fw = {
          family = "inet";
          content = ''
            chain output {
              type filter hook output priority 0; policy accept;
              ${cfg.extraOutputRules}
            }
          '';
        };
      };
    };
}
