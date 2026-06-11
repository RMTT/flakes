{ lib, config, ... }:
let
  cfg = config.machine.bootloader;
in
{
  options.machine.bootloader = {
    grub = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
      device = lib.mkOption {
        type = lib.types.str;
        default = "nodev"; # for UEFI
        description = "nodev for UEFI or actual disk device for bios";
      };
    };
    systemd-boot = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.grub.enable {
      boot.loader.efi.canTouchEfiVariables = true;

      boot.loader.grub = {
        enable = true;
        configurationLimit = 10;
        efiSupport = true;
        device = cfg.grub.device;
      };
    })
    (lib.mkIf cfg.systemd-boot.enable {
      boot.loader.efi.canTouchEfiVariables = true;

      boot.loader.systemd-boot = {
        enable = true;
        configurationLimit = 10;
        editor = false;
      };
    })
  ];
}
