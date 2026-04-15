{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.godel.overlay;
  godelCfg = config.services.godel;
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
  hasEndpoint = entry: entry ? "endpoint";
  registry = (import ./registry.nix);
  hostName = config.networking.hostName;
  ownRegistry = registry.${hostName};
  filteredRegistry =
    if (hasEndpoint ownRegistry) then
      lib.filterAttrs (name: _: name != hostName) registry
    else
      lib.filterAttrs (name: value: name != hostName && (hasEndpoint value)) registry;
in
{
  options = {
    services.godel.overlay = {
      enable = mkEnableOption "enable godel service";

      xfrm = mkEnableOption "enable route-based";
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
      address =mkIf cfg.xfrm [ "${godelCfg.infra-ip}/24" ];
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
        charon-systemd {
          journal {
            default = 1
          }
        }
        charon {
          port = 0
          port_nat_t = 41821
          retransmit_tries = 20
          retransmit_base = 1.4
        }
      '';
      includes = [ config.sops.secrets.swanctl.path ];
      swanctl = {
        connections = mapAttrs (name: value: {
          version = 2;
          dpd_delay = "15s";
          remote_addrs = mkIf (hasEndpoint value) [ value.endpoint ];
          remote_port = mkIf (hasEndpoint value) port;
          local_port = port;
          if_id_in = "1024";
          if_id_out = "1024";
          local.main = {
            auth = "psk";
            id = config.networking.hostName;
          };
          remote.main = {
            auth = "psk";
            id = name;
          };
          children.main = {
            local_ts = ownRegistry.subnets;
            remote_ts = value.subnets;
            start_action = if (hasEndpoint ownRegistry) then "trap" else "start";
            close_action = if (hasEndpoint ownRegistry) then "trap" else "start";
            dpd_action = if (hasEndpoint ownRegistry) then "clear" else "restart";
            updown = "${updown}";
          };
        }) filteredRegistry;
      };
    };
  };
}
