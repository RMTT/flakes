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
    services.hermes-agent = {
      enable = true;
      user = "mt";
      group = "mt";
      createUser = false;
      environmentFiles = [ config.sops.secrets.env.path ];
      addToSystemPackages = true;
      extraPackages = with pkgs; [ docker ];
      settings = {
        toolsets = [ "all" ];
        memory = {
          memory_enabled = true;
          user_profile_enabled = true;
        };
        terminal = {
          backend = "docker";
          cwd = config.services.hermes-agent.workingDirectory;
        };
      };
    };
  };
}
