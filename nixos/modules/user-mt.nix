{ config, lib, ... }:
let
  cfg = config.machine.users.mt;
in
with lib;
{

  options.machine.users.mt = {
    enable = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    nix.settings.trusted-users = [
      "mt"
    ];

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
        (mkIf config.virtualisation.docker.enable "docker")
        (mkIf config.virtualisation.incus.enable "incus-admin")
        "video"
        "kvm"
        "users"
        "uinput"
        "i2c"
        "wireshark"
        (mkIf config.virtualisation.libvirtd.enable "libvirtd")
      ];
      initialHashedPassword = "$y$j9T$v3KSiMJEpJdcbN4osJbMF0$Qfgg9i/ozgLjDhOg/WZmSrg8vuiNQSrSWivWKvjATN7";
      openssh.authorizedKeys.keyFiles = [ ./secrets/ssh_key.pub ];
    };
  };
}
