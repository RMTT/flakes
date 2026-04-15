{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.machine.desktop;
in
with lib;
{

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      niri
      fuzzel
      kitty
      alacritty
      xwayland-satellite
      wl-clipboard-rs

      kdePackages.qtwayland
      kdePackages.qt6ct
      libsForQt5.qt5.qtwayland
      qadwaitadecorations
      qadwaitadecorations-qt6
      networkmanagerapplet
      blueman

      slurp
      grim
      satty
      (pkgs.writeScriptBin "screenshot" ''grim -g "$(slurp)" -t ppm - | satty --filename -'')
      brightnessctl
      gpu-screen-recorder
      wlsunset
      cava
      matugen
      cliphist

      # gnome apps
      nautilus
      seahorse
      loupe
      file-roller
      evince
      loupe
      gnome-text-editor
      gnome-system-monitor
    ];

    # qt theme
    qt = {
      enable = true;
      platformTheme = "qt5ct";
      style = "adwaita";
    };

    # to use gnome apps
    services.gvfs.enable = true;
    services.gnome.sushi.enable = true;
    services.gnome.gnome-software.enable = true;
    services.gnome.gnome-keyring.enable = true;
    services.gnome.tinysparql.enable = true;
    services.gnome.localsearch.enable = true;
    programs.gnome-disks.enable = true;

    services.upower.enable = true;
    services.power-profiles-daemon.enable = true;

    services.displayManager.sessionPackages = with pkgs; [ niri ];
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      wayland.compositor = "kwin";
      extraPackages = with pkgs; [
        sddm-astronaut
        adwaita-icon-theme
        kdePackages.qtsvg
        kdePackages.qtvirtualkeyboard
        kdePackages.qtmultimedia
      ];
      theme = "sddm-astronaut-theme";
      settings = {
        Theme = {
          CursorTheme = "Adwaita";
          CursorSize = 24;
        };
      };
    };

    security.polkit.enable = true;
    security.pam.services.hyprlock = { };

    xdg.portal = {
      enable = true;
      configPackages = [ pkgs.niri ];
      extraPortals = with pkgs; [
        xdg-desktop-portal-gnome
        xdg-desktop-portal-gtk
      ];
    };

    programs.gnupg.agent.pinentryPackage = mkForce pkgs.pinentry-gnome3;
    xdg.mime = {
      enable = true;
      defaultApplications = {
        "inode/directory" = "org.gnome.Nautilus.desktop";

        "text/html" = "firefox.desktop";
        "application/xhtml+xml" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "x-scheme-handler/about" = "firefox.desktop";

        "application/pdf" = "org.gnome.Evince.desktop";

        "image/jpeg" = "org.gnome.Loupe.desktop";
        "image/png" = "org.gnome.Loupe.desktop";
        "image/gif" = "org.gnome.Loupe.desktop";
        "image/webp" = "org.gnome.Loupe.desktop";
        "image/svg+xml" = "org.gnome.Loupe.desktop";
        "image/bmp" = "org.gnome.Loupe.desktop";
        "image/tiff" = "org.gnome.Loupe.desktop";

        "text/plain" = "org.gnome.TextEditor.desktop";
      };
    };
  };
}
