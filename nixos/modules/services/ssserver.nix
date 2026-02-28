{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.ssserver;
in
{
  options = {
    services.ssserver = {
      enable = mkEnableOption "Shadowsocks-Rust Server";

      package = mkOption {
        type = types.package;
        default = pkgs.shadowsocks-rust;
        description = "The shadowsocks-rust package to use.";
      };

      listenAddress = mkOption {
        type = types.str;
        default = "0.0.0.0";
        description = "Listen address for the server.";
      };

      port = mkOption {
        type = types.port;
        default = 8388;
        description = "Listen port for the server.";
      };

      method = mkOption {
        type = types.str;
        default = "aes-256-gcm";
        description = "Encryption method (e.g., aes-256-gcm, chacha20-ietf-poly1305).";
      };

      passwordFile = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Path to a file containing the password. Use a string path instead of a path literal to prevent secrets from being copied to the Nix store.";
      };

      configFile = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Path to a JSON configuration file. If specified, this overrides listenAddress, port, method, and passwordFile.";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to open the firewall for the specified port (only applies if not using configFile).";
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.configFile == null -> cfg.passwordFile != null;
        message = "services.ssserver: You must specify either configFile or passwordFile.";
      }
    ];

    systemd.services.ssserver = {
      description = "Shadowsocks-Rust Server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        RuntimeDirectory = "ssserver";
        Restart = "always";
        LimitNOFILE = 32768;

        # Hardening
        CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";
        AmbientCapabilities = "CAP_NET_BIND_SERVICE";
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
      }
      // (
        if cfg.configFile != null then
          {
            ExecStart = "${cfg.package}/bin/ssserver -c ${cfg.configFile}";
          }
        else
          {
            ExecStart = "${pkgs.writeShellScript "ssserver-start" ''
              export SS_PASSWORD=$(< ${cfg.passwordFile})
              exec ${cfg.package}/bin/ssserver \
                -s ${cfg.listenAddress}:${toString cfg.port} \
                -m ${cfg.method} \
                -k "$SS_PASSWORD"
            ''}";
          }
      );
    };

    networking.firewall = mkIf (cfg.openFirewall && cfg.configFile == null) {
      allowedTCPPorts = [ cfg.port ];
      allowedUDPPorts = [ cfg.port ];
    };
  };
}
