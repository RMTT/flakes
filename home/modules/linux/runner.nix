{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.walker = {
    enable = true;
    runAsService = true;

    # All options from the config.toml can be used here.
    config = {
      placeholders."default".input = "try something";
    };

    # If this is not set the default styling is used.
    theme.style = ''
      * {
        color: #dcd7ba;
      }
    '';
  };

  systemd.user.services.elephant = {
    Unit = {
      After = [ "graphical-session.target" ];
    };
  };
}
