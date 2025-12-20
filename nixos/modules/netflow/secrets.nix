{ config, lib, ... }:
let
  cfg = config.services.netflow;
in
{
  config = lib.mkIf cfg.enable {
    sops.secrets.singbox = {
      mode = "0400";
      sopsFile = ./config.json;
      format = "binary";
    };
  };
}
