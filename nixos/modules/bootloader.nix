{ lib, config, ... }:
let
  cfg = config.machine.bootloader;
in
{
  options.machine.bootloader = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };
  config = lib.mkIf cfg.enable {
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    boot.loader.systemd-boot.configurationLimit = 10;
    boot.loader.grub.configurationLimit = 10;
  };
}
