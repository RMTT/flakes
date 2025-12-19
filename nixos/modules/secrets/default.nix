{ config, lib, ... }:
let
  keyFilePath = "/var/lib/sops-nix/age";
  cfg = config.machine.secrets;
in
with lib;
{
  options.machine.secrets = {
    enable = mkOption {
      type = types.bool;
      description = "apply default secrets config";
      default = false;
    };
  };

  config = mkIf cfg.enable {
    sops.defaultSopsFile = ./keys.yaml;
    sops.age.keyFile = keyFilePath;
    sops.age.generateKey = false;
  };
}
