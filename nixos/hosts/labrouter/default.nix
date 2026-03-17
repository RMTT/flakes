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

  config =
    let
      infra_node_ip = "198.19.198.254";
    in
    {
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

      environment.systemPackages = with pkgs; [ kmod ];

      #  services.godel = {
      #    overlay = {
      #      enable = true;
      #      ip = infra_node_ip;
      #    };
      # };
    };
}
