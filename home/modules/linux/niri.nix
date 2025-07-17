{ config, lib, pkgs, ... }: {

  imports = [ ./waybar.nix ./hyprlock.nix ];
  xdg.configFile = {
    niri = {
      enable = true;
      source = ../../config/niri;
    };

    fuzzel = {
      enable = true;
      source = ../../config/fuzzel;
    };
  };

  # https://fcitx-im.org/wiki/Using_Fcitx_5_on_Wayland
  home.sessionVariables = {
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
  };

  home.packages = with pkgs; [
    qadwaitadecorations
    qadwaitadecorations-qt6

    # for screencast
    slurp
    grim
    satty
    (pkgs.writeScriptBin "screenshot"
      ''grim -g "$(slurp)" -t ppm - | satty --filename -'')
  ];

  services.swayidle = {
    enable = true;
    timeouts = [
      {
        timeout = 599;
        command = "${pkgs.niri}/bin/niri msg action power-off-monitors";
      }
      {
        timeout = 600;
        command = "${pkgs.hyprlock}/bin/hyprlock";
      }
    ];
  };

  services.swww.enable = true; # for wallpapaer
  services.mako = {
    enable = true;
    settings = {
      icon-path = "${pkgs.numix-icon-theme}/share/icons/Numix";
      font = "monospace 12";

      # colors: https://github.com/catppuccin/mako/blob/main/themes/catppuccin-mocha/catppuccin-mocha-sky
      background-color = "#1e1e2e";
      text-color = "#cdd6f4";
      border-color = "#89dceb";
      progress-color = "over #313244";
      "urgency=high" = { border-color = "#fab387"; };
    };
  };
}
