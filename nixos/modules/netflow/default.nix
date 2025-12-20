# netflow will split network traffics via destination(inside or outside of china).
# netflow uses sing-box + nftables for traffic routing and adguardhome + mosdns for dns routing.
#
# progress to start netflow:
# 1. adguardhome should start firstly, and use singbox and other domain specific rules as upstreams.
# 2. singbox should not dependent other apps to launch, it means singbox has to resolve domains such as node's domain and rulesets's domain in itself
# 3. nftable's table 'netflow' will direct udp and tcp traffic to singbox's transparent proxy except it in several sets:
#     reserve4  # reserve ips should not be directed to singbox
#     reserve6
#     direct4   # ips from other apps should not be directed to singbox
#     direct6
{
  pkgs,
  lib,
  config,
  ...
}:
let
  stateDir = "/var/lib/netflow";
  fwmark = "5000";
  cfg = config.services.netflow;
in
with lib;
{
  imports = [
    ./secrets.nix
  ];

  options.services.netflow = {
    enable = mkEnableOption "enable netflow";
    interface = lib.mkOption { type = lib.types.str; };
  };

  config = mkIf cfg.enable {
    boot.kernelModules = [
      "nf_tproxy_ipv6"
      "nf_tproxy_ipv4"
      "nft_tproxy"
    ];

    # services.gost = {
    #   enable = true;
    # };
    services.singbox = {
      enable = true;
      configFile = config.sops.secrets.singbox.path;
    };

    systemd.services.netflow = {
      wantedBy = [ "multi-user.target" ];
      path = [
        pkgs.iproute2
        pkgs.coreutils
      ];
      script = ''
        if [ ! -d "${stateDir}" ]; then
          mkdir -p ${stateDir}
        fi

        ip ru add priority 32000 fwmark ${fwmark} lookup 200 || true
        ip -6 ru add priority 32000 fwmark ${fwmark} lookup 200 || true

        ip r flush table 200 || true
        ip r add local 0.0.0.0/0 dev lo table 200 || true

        ip -6 r flush table 200 || true
        ip -6 r add local ::/0 dev lo table 200 || true

        # create filter lists
        # if [ ! -e "${stateDir}/chnlist.txt" ]; then
        #   touch "${stateDir}/chnlist.txt"
        # fi
        # cp ${./sets/reserve_domains.txt} "${stateDir}/reserve_domains.txt"
      '';
      serviceConfig = {
        Type = "oneshot";
      };
    };

    networking.nftables.tables.netflow = {
      name = "netflow";
      content = ''
        define TPROXY_PORT=7890
        define FWMARK=${fwmark}
        define PROXY_MARK=5001

        define proxy_protocols = { tcp, udp }

        include "${./sets/reserve.nft}"

        set reserve4 {
          type ipv4_addr;
          flags interval
          auto-merge
          elements = $reserve_v4
        }
        set reserve6 {
          type ipv6_addr;
          flags interval
          auto-merge
          elements = $reserve_v6
        }

        # following two sets will be filled by other apps dynamically
        set direct4 {
          type ipv4_addr;
          flags interval
          auto-merge
        }
        set direct6 {
          type ipv6_addr;
          flags interval
          auto-merge
        }


        chain output {
          type route hook output priority mangle; policy accept;

          meta mark $PROXY_MARK return comment "traffic from proxy"

          # common rules
          meta l4proto != $proxy_protocols return comment "filter protocols to proxy"

          ip dscp 4 return comment "direct traffic"
          ip6 dscp 4 return comment "direct traffic"

          fib daddr type {local,broadcast,anycast,multicast} return

          ip daddr @reserve4 return
          ip daddr @direct4 return
          ip6 daddr @reserve6 return
          ip6 daddr @direct6 return

          meta protocol ip meta l4proto $proxy_protocols meta mark set $FWMARK
          meta protocol ip6 meta l4proto $proxy_protocols meta mark set $FWMARK
        }

        chain prerouting {
          type filter hook prerouting priority mangle; policy accept;

          # common rules
          meta l4proto != $proxy_protocols return comment "filter protocols to proxy"

          ip dscp 4 return comment "direct traffic"
          ip6 dscp 4 return comment "direct traffic"

          fib daddr type {local,broadcast,anycast,multicast} return

          ip daddr @reserve4 return
          ip daddr @direct4 return
          ip6 daddr @reserve6 return
          ip6 daddr @direct6 return

          meta protocol ip meta l4proto $proxy_protocols tproxy ip to :$TPROXY_PORT meta mark set $FWMARK
          meta protocol ip6 meta l4proto $proxy_protocols tproxy ip6 to :$TPROXY_PORT meta mark set $FWMARK
        }
      '';
      family = "inet";
    };

    networking.firewall.extraReversePathFilterRules = "meta mark ${fwmark} accept";
  };
}
