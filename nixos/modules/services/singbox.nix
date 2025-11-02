{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.services.singbox;
in
{
  options = {
    services.singbox = {
      enable = mkEnableOption "enable singbox";

      configFile = mkOption {
        type = types.path;
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.singbox = {
      serviceConfig = {
        StateDirectory = "singbox";
        StateDirectoryMode = "0700";
        RuntimeDirectory = "singbox";
        RuntimeDirectoryMode = "0700";
        WorkingDirectory = "/var/lib/singbox";
        CapabilityBoundingSet = [
          "CAP_NET_ADMIN"
          "CAP_NET_RAW"
          "CAP_NET_BIND_SERVICE"
          "CAP_SYS_PTRACE"
          "CAP_DAC_READ_SEARCH"
        ];
        AmbientCapabilities = [
          "CAP_NET_ADMIN"
          "CAP_NET_RAW"
          "CAP_NET_BIND_SERVICE"
          "CAP_SYS_PTRACE"
          "CAP_DAC_READ_SEARCH"
        ];
        ExecStart = [ "${lib.getExe pkgs.sing-box} -c ${cfg.configFile} -D $STATE_DIRECTORY run" ];
      };
      wantedBy = [ "multi-user.target" ];
    };
  };
}
