{ config, lib, ... }:
let
  cfg = config.machine.secrets;
in
{
  options.machine.secrets = {
    enable = lib.mkOption {
      type = lib.types.bool;
      description = "apply default secrets config";
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {
    sops.age.generateKey = false;
  };
}
