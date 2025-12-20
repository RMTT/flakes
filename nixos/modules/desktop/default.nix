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
    ./niri.nix
  ];

  options.machine.desktop = {
    enable = mkEnableOption "enable desktop (based on niri)";
  };

  config = mkIf cfg.enable {
    services.printing = {
      enable = true;
      drivers = with pkgs; [ fxlinuxprint ];
    };

    environment.systemPackages = with pkgs; [
      ddcutil
      sddm-astronaut
      libnotify
      qpwgraph
    ];

    boot.kernelModules = [ "i2c-dev" ];
    services.udev.extraRules = ''
      KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"
    '';

    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    services.greetd = {
      enable = true;
      useTextGreeter = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --remember-user-session -r";
          user = "greeter";
        };
      };
    };

    services.geoclue2 = {
      enable = true;
      geoProviderUrl = "https://beacondb.net/v1/geolocate";
    };
    services.avahi.enable = true;
  };
}
