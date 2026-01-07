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
  imports = [
    ./secrets.nix
  ];

  options.services.netflow = {
    enable = mkEnableOption "enable netflow";
  };

  config = mkIf cfg.enable {
    services.singbox = {
      enable = true;
      configFile = config.sops.secrets.singbox.path;
    };

    networking.firewall.trustedInterfaces = [ "sing-box" ];
  };
}
