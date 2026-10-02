{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.machine.opengpg;
in
{
  options.machine.opengpg = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
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
        enableExtraSocket = true;
      };
    };
  };
}
