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

  # color theme is managed by noctalia
  gtk = {
    enable = true;
    iconTheme = {
      name = "Numix";
      package = pkgs.numix-icon-theme;
    };
    gtk4.theme = config.gtk.theme;
  };

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    name = "Adwaita";
    size = 24;
    package = pkgs.adwaita-icon-theme;
  };

  xresources.properties = {
    "Xft.dpi" = 120;
  };
}
