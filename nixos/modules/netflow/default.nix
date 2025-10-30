# services order: gost + netflow -> netflow-update -> mosdns
# workflow: after gost launched, it'd download subcriptions and this process doesn't need outer dns.
# Then the proxy can be used to download other resources(netflow-update)
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
{
  options = {
    services.netflow = {
      interface = lib.mkOption { type = lib.types.str; };
    };
  };
  imports = [
    ./secrets.nix
    ../services/gost.nix
  ];
  config = {
    boot.kernelModules = [
      "nf_tproxy_ipv6"
      "nf_tproxy_ipv4"
      "nft_tproxy"
    ];

    services.gost = {
      enable = true;
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
        if [ ! -e "${stateDir}/chnlist.txt" ]; then
          touch "${stateDir}/chnlist.txt"
        fi
        cp ${./sets/reserve_domains.txt} "${stateDir}/reserve_domains.txt"
      '';
      serviceConfig = {
        Type = "oneshot";
      };
    };

    systemd.services.netflow-update = {
      after = [
        "netflow.service"
        "network-online.service"
        "gost.service"
        "nftables.service"
      ];
      wantedBy = [ "multi-user.target" ];
      path = [
        pkgs.python3
        pkgs.curl
        pkgs.nftables
      ];
      environment = {
        ALL_PROXY = "socks5://127.0.0.1:7891";
        HTTP_PROXY = "socks5://127.0.0.1:7891";
        HTTPS_PROXY = "socks5://127.0.0.1:7891";
      };
      script = ''
        # when host reboot, it will load previous data
        if [ -e ${stateDir}/ipv4_list.nft ]; then
          nft -f ${stateDir}/ipv4_list.nft
        fi
        if [ -e ${stateDir}/ipv6_list.nft ]; then
          nft -f ${stateDir}/ipv6_list.nft
        fi

        until curl -I -s https://www.google.com >/dev/null
        do
          echo "wait to that i can visit internet..."
          sleep 10
        done

        # update domain list
        curl -s -f -m 30 'https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/accelerated-domains.china.conf' -o ${stateDir}/chnlist.txt.new
        if [ "$?" = "0" ]; then
          python ${./convert.py} domain ${stateDir}/chnlist.txt.new ${stateDir}/chnlist.txt.new

          old_md5=$(md5sum ${stateDir}/chnlist.txt)
          new_md5=$(md5sum ${stateDir}/chnlist.txt.new)

          if [ "$old_md5" != "$new_md5" ]; then
            mv ${stateDir}/chnlist.txt.new ${stateDir}/chnlist.txt
          fi
        fi

        # update ip list
        curl -s -f -m 30 'https://raw.githubusercontent.com/fernvenue/chn-cidr-list/master/ipv4.txt' -o ${stateDir}/ipv4_list.txt
        if [ "$?" = "0" ]; then
          python ${./convert.py} ip --set 'inet netflow direct4' ${stateDir}/ipv4_list.txt ${stateDir}/ipv4_list.nft
          nft -f ${stateDir}/ipv4_list.nft
        fi


        curl -s -f -m 30 'https://raw.githubusercontent.com/fernvenue/chn-cidr-list/master/ipv6.txt' -o ${stateDir}/ipv6_list.txt
        if [ "$?" = "0" ]; then
          python ${./convert.py} ip --set 'inet netflow direct6' ${stateDir}/ipv6_list.txt ${stateDir}/ipv6_list.nft
          nft -f ${stateDir}/ipv6_list.nft
        fi
      '';
      serviceConfig = {
        Type = "oneshot";
      };
    };
    systemd.timers.netflow-update = {
      after = [
        "netflow.service"
        "network-online.service"
        "gost.service"
      ];
      wantedBy = [ "multi-user.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Unit = "netflow-update.service";
      };
    };

    # mosdns needs chnlist for work, so wait until netflow-update completing
    systemd.services.mosdns = {
      after = [
        "netflow.service"
        "gost.service"
      ];
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.mosdns ];
      script = "mosdns start -c ${./mosdns.yaml}";
      serviceConfig = {
        Type = "simple";
      };
    };
    systemd.paths.chnlist = {
      after = [
        "gost.service"
        "netflow.service"
        "netflow-update.service"
      ];
      pathConfig = {
        PathChanged = "${stateDir}";
        Unit = "mosdns.service";
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
