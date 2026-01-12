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
    (pkgs.writeScriptBin "screenshot" ''grim -g "$(slurp)" -t ppm - | satty --filename -'')
    noctalia-shell
    brightnessctl
    gpu-screen-recorder
    wlsunset
    cava
    matugen
    cliphist
  ];

  services.swayidle = {
    enable = true;
    timeouts = [
      {
        timeout = 600;
        command = "${pkgs.noctalia-shell}/bin/noctalia-shell ipc call lockScreen lock";
      }
      # {
      #   timeout = 1800;
      #   command = "${pkgs.niri}/bin/niri msg action power-off-monitors";
      #   # close all monitor will cause systemd-logind starting suspend
      # }
    ];
  };
}
