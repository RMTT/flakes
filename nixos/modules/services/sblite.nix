{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.sblite;
in
{
  options.services.sblite = {
    enable = mkEnableOption "sblite, a lightweight proxy client based on sing-box";

    package = mkOption {
      type = types.package;
      default = pkgs.sblite;
      description = "The sblite package to use.";
    };

    listenAddress = mkOption {
      type = types.str;
      default = "127.0.0.1:8180";
      description = "The address and port sblite should listen on.";
    };

    stateDirectory = mkOption {
      type = types.str;
      default = "/var/lib/sblite";
      description = ''
        The state directory containing sing-box config and other data.
        If this is set to the default value, systemd will manage the directory.
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.services.sblite = {
      description = "sblite - A lightweight proxy client based on sing-box";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      # iproute2 is required for iproute2 resources
      path = [ pkgs.iproute2 ];

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/sblite --listen ${cfg.listenAddress} --state-directory ${cfg.stateDirectory}";
        Restart = "on-failure";
        RestartSec = "5s";

        # Systemd automatically creates this directory with correct permissions when it starts
        StateDirectory = lib.mkIf (cfg.stateDirectory == "/var/lib/sblite") "sblite";

        # Capabilities needed to bind address, create tun device, and manage routing
        AmbientCapabilities = [
          "CAP_NET_ADMIN"
          "CAP_NET_BIND_SERVICE"
          "CAP_NET_RAW"
        ];
        CapabilityBoundingSet = [
          "CAP_NET_ADMIN"
          "CAP_NET_BIND_SERVICE"
          "CAP_NET_RAW"
        ];

        # Device Allow for tun creation
        DeviceAllow = "/dev/net/tun rw";

        # Basic Hardening
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
      };
    };
  };
}
