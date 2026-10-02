{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.machine.users.mt;
in
{
  options.machine.users.mt = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    hashedPassword = lib.mkOption {
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    # main user
    security.sudo = {
      wheelNeedsPassword = false;
    };
    users.mutableUsers = true;
    users.groups.mt = {
      gid = 1000;
    };
    users.users.mt = {
      isNormalUser = true;
      home = "/home/mt";
      description = "mt";
      group = "mt";
      uid = 1000;
      extraGroups = [
        "wheel"
        "networkmanager"
        (lib.mkIf config.virtualisation.docker.enable "docker")
        (lib.mkIf config.virtualisation.incus.enable "incus-admin")
        "video"
        "kvm"
        "users"
        "uinput"
        "input"
        (lib.mkIf config.hardware.i2c.enable "i2c")
        "wireshark"
        (lib.mkIf config.virtualisation.libvirtd.enable "libvirtd")
        (lib.mkIf config.programs.librepods.enable "librepods")
      ];
      hashedPassword = cfg.hashedPassword;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHBjkW0ansGOkZCBkjyf5RArK+Amtxw7W/FeNV6GaRfG openpgp:0x15215C93"
      ];
    };

  };
}
