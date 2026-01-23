{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.services.netflow;
in
with lib;
{
  options.services.netflow = {
    enable = mkEnableOption "enable netflow";
  };

  config = mkIf cfg.enable {
    # services.singbox = {
    #   enable = true;
    #   configFile = config.sops.secrets.singbox.path;
    # };
    # networking.firewall.trustedInterfaces = [ "sing-box" ];
    # sops.secrets.singbox = {
    #   mode = "0400";
    #   sopsFile = ./config.json;
    #   format = "binary";
    # };

    sops.secrets.mihomo = {
      mode = "0400";
      sopsFile = ./config.yaml;
      format = "binary";
    };
    services.mihomo = {
      enable = true;
      tunMode = true;
      configFile = config.sops.secrets.mihomo.path;
    };
    networking.firewall.trustedInterfaces = [ "Meta" ];
  };
}
