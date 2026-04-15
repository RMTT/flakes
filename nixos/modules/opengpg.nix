{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.machine.opengpg;
in
{
  options.machine.opengpg = {
    enable = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      sequoia-sq
      sequoia-wot
      sequoia-sqv
      sequoia-sqop
      sequoia-chameleon-gnupg
      openpgp-card-tools
      ccid
    ];
    environment.variables = {
      GPG_TTY = "$(tty)";
    };

    services.udev.packages = [ pkgs.yubikey-personalization ];
    services.pcscd.enable = true;

    programs.gnupg = {
      agent = {
        enable = true;
        enableSSHSupport = true;
        pinentryPackage = mkDefault pkgs.pinentry-tty;
        enableExtraSocket = true;
      };
    };
  };
}
