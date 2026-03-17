{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.godel.overlay;
  port = 41821;
  updown = pkgs.writeScript "updown" ''
    #!${pkgs.bash}/bin/bash
    XFRM_IF="godel"

    if [ "''${PLUTO_VERB}" == "up-client" ]; then
      ${pkgs.iproute2}/bin/ip route add ''${PLUTO_PEER_CLIENT} dev ''${XFRM_IF} || true
    elif [ "''${PLUTO_VERB}" == "down-client" ]; then
      ${pkgs.iproute2}/bin/ip route del ''${PLUTO_PEER_CLIENT} dev ''${XFRM_IF} || true
    fi
  '';
  registry = (import ./registry.nix).${cfg.mode};
in
{
  options = {
    services.godel.overlay = {
      enable = mkEnableOption "enable godel service";

      ip = mkOption {
        type = types.str;
        description = "Remote endpoint IP address of the VPN";
      };

      mode = mkOption {
        type = types.enum [
          "client"
          "server"
        ];
        default = "client";
        description = "Mode of operation";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.network.netdevs."42-xfrm0" = {
      netdevConfig = {
        Name = "godel";
        Kind = "xfrm";
      };
      xfrmConfig = {
        InterfaceId = 1024;
        Independent = true;
      };
    };

    systemd.network.networks."42-xfrm0" = {
      matchConfig.Name = "godel";
      address = [ "${cfg.ip}/24" ];
      linkConfig = {
        ActivationPolicy = "always-up";
        RequiredForOnline = "no";
        MTUBytes = "1360";
      };
    };
    networking.firewall.trustedInterfaces = [ "godel" ];
    networking.firewall.allowedUDPPorts = [ port ];

    environment.systemPackages = [ pkgs.strongswan ];

    sops.secrets.swanctl = {
      sopsFile = ./swanctl.conf;
      format = "binary";
    };
    services.strongswan-swanctl = {
      enable = true;
      strongswan.extraConfig = ''
        charon {
          port = 0
          port_nat_t = 41821
          retransmit_limit = 0
        }
      '';
      includes = [ config.sops.secrets.swanctl.path ];
      swanctl = {
        connections = builtins.listToAttrs (
          map (entry: {
            name = entry.name;
            value = {
              version = 2;
              dpd_delay = "15s";
              remote_addrs = mkIf (cfg.mode == "client") [ "cn2-box.rmtt.host" ];
              remote_port = port;
              local_port = port;
              if_id_in = "1024";
              if_id_out = "1024";
              local.main = {
                auth = "psk";
                id = config.networking.hostName;
              };
              remote.main = {
                auth = "psk";
                id = entry.name;
              };
              children.main = {
                local_ts = [ "0.0.0.0/0" ];
                remote_ts = entry.subnets;
                start_action = if (cfg.mode == "server") then "trap" else "start";
                close_action = if (cfg.mode == "server") then "trap" else "start";
                updown = "${updown}";
              };
            };
          }) registry
        );
      };
    };
  };
}
