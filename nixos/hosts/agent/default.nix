{
  pkgs,
  lib,
  config,
  modulesPath,
  ...
}:
with lib;
{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
    ./secrets
  ];

  config = {
    system.stateVersion = "26.05";

    networking.useNetworkd = true;
    machine.graphics.enable = false;
    machine.development.enable = true;
    machine.users.mt.hashedPassword = "$y$j9T$H5wxavXJIZ0LE9qbqAsMw/$k6vzXefc9AniNzapi0NGKdgyL82afXqHxzQwYOvFNA6";
    nixpkgs.hostPlatform = "x86_64-linux";
    nix.settings = {
      sandbox = false;
    };
    proxmoxLXC.privileged = true;
    proxmoxLXC.manageNetwork = true;
    networking.useHostResolvConf = false;
    services.fstrim.enable = false; # Let Proxmox host handle fstrim
    # have to suppress these units, since they do not work inside LXC
    systemd.suppressedSystemUnits = [
      "sys-kernel-debug.mount"
    ];

    virtualisation.docker = {
      enable = true;
    };
  };
}
