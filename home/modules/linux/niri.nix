{
  config,
  lib,
  pkgs,
  ...
}:
{
  xdg.configFile = {
    niri = {
      enable = true;
      source = ../../config/niri;
    };
  };

  home.packages = with pkgs; [
    noctalia-shell
  ];
}
