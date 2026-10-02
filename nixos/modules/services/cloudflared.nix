{
  config,
  lib,
  pkgs,
  ...
}:


let
  cfg = config.services.cloudflare-tunnel;
in
{
  options.services.cloudflare-tunnel = {
    enable = lib.mkEnableOption "Cloudflare Tunnel";

    tokenFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to the Cloudflare Tunnel token file.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.cloudflare-tunnel = {
      description = "Cloudflare Tunnel";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "${lib.getExe pkgs.cloudflared} tunnel run --token-file ${cfg.tokenFile}";
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };
  };
}
