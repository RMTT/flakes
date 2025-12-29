{ lib, config, ... }:
with lib;
let
  cfg = config.services.godel;
in
mkIf cfg.enable {

  sops.secrets.godel = {
    mode = "0400";
    sopsFile = ./authkey;
    format = "binary";
  };
  sops.secrets.k3s-token = {
    mode = "0400";
    sopsFile = ./k3s-token;
    format = "binary";
  };
}
