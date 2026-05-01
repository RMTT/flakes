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
    boot.loader.systemd-boot.enable = mkForce false;
    machine.graphics.enable = false;
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

    programs.nix-ld = {
      enable = true;
    };

    virtualisation.docker = {
      enable = true;
    };
  };
}
