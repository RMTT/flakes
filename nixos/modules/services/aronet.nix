{ config, lib, pkgs, ... }:
with lib;

let cfg = config.services.aronet;
in {
  options = {
    services.aronet = {
      enable = mkEnableOption "enable aronet";

      config = mkOption {
        type = types.path;
        description = "aronet config file path";
      };
      registry = mkOption {
        type = types.path;
        description = "aronet registry file path";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.aronet ];
    networking.firewall.allowedUDPPorts = [ 12025 6696 ];
    systemd.services.aronet = {
      description = "aronet service";
      wantedBy = [ "multi-user.target" ];
      path = with pkgs; [ bash iproute2 nftables ];
      after = [
        "network.target"
        "NetworkManager.service"
        "systemd-networkd.service"
        "iwd.service"
      ];
      script =
        "${pkgs.aronet}/bin/aronet -c ${cfg.config} -r ${cfg.registry} daemon run";
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        LimitNPROC = 500;
        LimitNOFILE = 1000000;
      };
    };
  };
}
