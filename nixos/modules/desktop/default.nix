{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.machine.desktop;
in
{
  imports = [
    ./desktop.nix
    ./pipewire.nix
    # ./niri.nix
    ./kde.nix
  ];

  options.machine.desktop = {
    enable = mkEnableOption "enable desktop (based on niri)";
  };

  config = mkIf cfg.enable {
    services.printing = {
      enable = true;
      drivers = with pkgs; [ fxlinuxprint ];
    };
    hardware.i2c.enable = true;
    boot.kernelModules = [ "i2c-dev" ];
    services.udev.extraRules = ''
      KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"
    '';

    environment.sessionVariables.NIXOS_OZONE_WL = "1";

  };
}
