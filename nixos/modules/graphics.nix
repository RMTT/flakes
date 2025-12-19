{pkgs, lib, config, ... }:
with lib;
let
  cfg = config.machine.graphics;
in
{
  options.machine.graphics = {
    enable = mkOption {
      type = types.bool;
      default = true;
    };

  };

  # opengl and hardware acc
  config = mkIf cfg.enable {
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
