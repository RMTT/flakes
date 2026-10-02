{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.machine.graphics;
in
{
  options.machine.graphics = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };

  };

  # opengl and hardware acc
  config = lib.mkIf cfg.enable {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        libva
        libva-vdpau-driver
        intel-vaapi-driver
        libvdpau-va-gl
      ];
    };
  };
}
