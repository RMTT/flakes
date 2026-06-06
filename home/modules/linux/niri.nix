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
    satty.source = ../../config/satty;
  };

  home.packages = with pkgs; [
    noctalia-shell
  ];
}
