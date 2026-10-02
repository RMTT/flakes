{
  lib,
  config,
  ...
}:
let
  cfg = config.networking.firewall;
in
{
  options = {
    networking.firewall = {
      trustedIpv4 = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };
      trustedIpv6 = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };

      extraOutputRules = lib.mkOption {
        type = lib.types.str;
        default = "";
      };
    };
  };

  config =
    let
      subnetsV4 = lib.concatStringsSep "," cfg.trustedIpv4;
      subnetsV6 = lib.concatStringsSep "," cfg.trustedIpv6;
    in
    {
      networking.firewall = {
        enable = true;
        checkReversePath = "loose";
        logRefusedConnections = false;
        logRefusedUnicastsOnly = false;
        extraInputRules = ''
          ${lib.optionalString (subnetsV4 != "") "ip saddr { ${subnetsV4} } accept"}
          ${lib.optionalString (subnetsV6 != "") "ip6 saddr { ${subnetsV6} } accept"}
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
