{ pkgs, lib, config, ... }:
with lib;
let cfg = config.services.gost;
in {
  options = {
    services.gost = {
      enable = mkEnableOption "enable gost";
      listen = mkOption {
        type = types.str;
        default = ":18080";
      };

      ui = mkEnableOption "enable gost-ui";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.gost = {
      path = [ pkgs.coreutils ];
      preStart = ''
        if [ ! -e gost.yaml ]; then
          touch gost.yaml
        fi
      '';
      serviceConfig = {
        StateDirectory = "gost";
        StateDirectoryMode = "0700";
        RuntimeDirectory = "gost";
        RuntimeDirectoryMode = "0700";
        WorkingDirectory = "/var/lib/gost";
        ExecStart =
          [ "${lib.getExe pkgs.gost} -api ${cfg.listen} -C gost.yaml" ];
      };
      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.gost-ui = {
      serviceConfig = {
        ExecStart = [
          "${
            lib.getExe pkgs.caddy
          } file-server --root ${pkgs.gost-ui} --listen :9090"
        ];
      };
      wantedBy = [ "multi-user.target" ];
    };
  };
}
