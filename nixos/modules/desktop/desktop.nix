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
    # many gtk apps need dconf
    programs.dconf.enable = true;

    # desktop apps
    environment.systemPackages = with pkgs; [
      tela-icon-theme
      numix-icon-theme
      solaar
      easyeffects
      firefox
      google-chrome
      xsettingsd
      vlc
      xrdb
      yubioath-flutter
      yubikey-manager
      yubikey-touch-detector
      yubikey-personalization
      yubico-pam

      insync
      insync-nautilus
    ];
    programs.sniffnet.enable = true;

    programs.appimage = {
      enable = true;
      binfmt = true;
    };
    systemd.services.flatpak-repo = {
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.flatpak ];
      script = ''
        flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
      '';
    };
    services.flatpak.enable = true;

    # fcitx5
    i18n.inputMethod = {
      type = "fcitx5";
      enable = true;
      fcitx5 = {
        waylandFrontend = true;
        addons = with pkgs; [
          fcitx5-mozc
          fcitx5-gtk
          qt6Packages.fcitx5-chinese-addons
          fcitx5-material-color
          fcitx5-pinyin-moegirl
          fcitx5-pinyin-zhwiki
        ];
      };
    };
    # fonts
    fonts.fontDir.enable = true;
    fonts.enableDefaultPackages = true;

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
    };

    # enable bluetooth
    hardware.bluetooth.enable = true;
    hardware.bluetooth.package = pkgs.bluez;

    # enable logitech
    hardware.logitech.wireless.enable = true;
    hardware.logitech.wireless.enableGraphical = true;
  };
}
