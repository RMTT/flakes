{ pkgs, lib, modules, config, ... }:
with lib; {
  imports = with modules; [ services base fs networking netflow ./secrets.nix ];

  config = let
    lan = [ "enp1s0" "enp2s0" "enp3s0" ];
    wan = "enp4s0";

    lan_gateway = "192.168.6.1"; # for DHCP and nat
    lan_ip_prefix = 24;
    lan_ip_subnet = "192.168.6.0/24";
    lan_ip_start = "192.168.6.10";
    lan_ip_end = "192.168.6.233";
  in {
    system.stateVersion = "23.05";
    base.gl.enable = false;

    fs.normal.volumes = {
      "/" = {
        fsType = "ext4";
        label = "@";
        options =
          [ "noatime" "data=writeback" "barrier=0" "nobh" "errors=remount-ro" ];
      };
    };
    fs.boot.label = "@boot";

    hardware.cpu.intel.updateMicrocode = true;

    # disable docker
    virtualisation.docker.enable = mkForce false;

    boot.kernel.sysctl = {
      # source: https://github.com/mdlayher/homelab/blob/master/nixos/routnerr-2/configuration.nix#L52
      # By default, not automatically configure any IPv6 addresses.
      "net.ipv6.conf.all.accept_ra" = 0;
      "net.ipv6.conf.all.autoconf" = 0;
      "net.ipv6.conf.all.use_tempaddr" = 0;

      # On WAN, allow IPv6 autoconfiguration and tempory address use.
      "net.ipv6.conf.${wan}.accept_ra" = 2;
      "net.ipv6.conf.${wan}.autoconf" = 1;
    };

    networking.useNetworkd = true;
    networking.bridges = {
      lan = { interfaces = lan; };
      wan = { interfaces = [ wan ]; };
    };
    # bypass lan
    networking.firewall.trustedInterfaces = [ "lan" "tailscale0" ];
    systemd.network = {
      networks = {
        wan = {
          name = "wan";
          networkConfig = { DHCP = "yes"; };
          dhcpV6Config = {
            WithoutRA = "solicit";
            UseDNS = false;
          };
          dhcpV4Config = { UseDNS = false; };
          ipv6AcceptRAConfig = { UseDNS = false; };
          dhcpPrefixDelegationConfig = {
            UplinkInterface = ":self";
            SubnetId = 0;
            Announce = "no";
          };
        };
        lan = {
          name = "lan";
          linkConfig = { ActivationPolicy = "always-up"; };
          networkConfig = {
            Address = "${lan_gateway}/${toString lan_ip_prefix}";
            ConfigureWithoutCarrier = "yes";
            IgnoreCarrierLoss = "yes";
            IPv6AcceptRA = "no";
            IPv6SendRA = "yes";
            DHCPPrefixDelegation = "yes";
          };
          dhcpPrefixDelegationConfig = {
            UplinkInterface = "wan";
            SubnetId = 1;
            Announce = "yes";
          };
        };
      };
    };
    services.resolved = {
      fallbackDns = null;
      extraConfig = ''
        DNS = 127.0.0.1
        DNSStubListener = false
        DNSSEC = false
        FallbackDNS =
      '';
    };

    # enable nat from lan
    networking.nat = {
      enable = true;
      internalIPs = [ "${lan_gateway}/${toString lan_ip_prefix}" ];
      externalInterface = "wan";
    };

    # enable adguardhome (for DNS and dhcp)
    services.adguardhome = {
      enable = true;
      allowDHCP = true;
      openFirewall = true;
    };

    # kea has bug when new interfaces added, use adguardhome as dhcp server now
    # services.kea = {
    #   dhcp4 = {
    #     enable = false;
    #     settings = {
    #       option-data = [
    #         {
    #           name = "domain-name-servers";
    #           data = "${lan_gateway}";
    #           always-send = true;
    #         }
    #         {
    #           name = "routers";
    #           data = "${lan_gateway}";
    #         }
    #       ];
    #       interfaces-config = {
    #         interfaces = [ "lan" ];
    #         service-sockets-require-all = true;
    #         service-sockets-max-retries = 50;
    #         service-sockets-retry-wait-time = 5000;
    #         dhcp-socket-type = "raw";
    #       };
    #       subnet4 = [{
    #         id = 1;
    #         pools = [{ pool = "${lan_ip_start} - ${lan_ip_end}"; }];
    #         subnet = "${lan_ip_subnet}";
    #         reservations = [
    #           {
    #             hw-address = "00:e0:4c:68:07:6e";
    #             hostname = "homeserver";
    #             ip-address = "192.168.6.2";
    #           }
    #           {
    #             hw-address = "20:88:10:a9:e7:3d";
    #             hostname = "homeserver";
    #             ip-address = "192.168.6.4";
    #           }
    #           {
    #             hw-address = "9e:20:b6:6d:b6:50";
    #             hostname = "pikvm";
    #             ip-address = "192.168.6.3";
    #           }
    #         ];
    #       }];
    #     };
    #   };
    # };

    services.netflow.interface = "wan";
    services.tailscale = {
      enable = true;
      openFirewall = true;
    };

    networking.wireguard.interfaces = {
      muconnect = {
        ips = [ "2001:db8:169::249/128" "198.18.169.249/32" ];
        privateKeyFile = config.sops.secrets.muconnect_key.path;
        extraOptions = { DNS = [ "2001:db8:169::1" "198.18.169.1" ]; };
        mtu = 1353;
        peers = [{
          publicKey = "jcfVGt+MSR3nKj7/yB9VY/3qqvClI2op1COrrDpyvQs=";
          endpoint = "muconnect-origin4.fernvenue.com:39573";
          allowedIPs = [ "2001:db8:169::/48" "198.18.169.0/24" ];
          persistentKeepalive = 30;
        }];
      };
    };

  };
}
