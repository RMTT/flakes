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
      infra_node_ip = "198.19.198.2";
      wan = "ens3";
    in
    {
      system.stateVersion = "25.05";

      networking.useNetworkd = true;
      boot.loader.systemd-boot.enable = mkForce false;

      machine.graphics.enable = false;
      zramSwap = {
        enable = true;
        memoryPercent = 25;
      };
      nix.settings = {
        sandbox = false;
      };
      proxmoxLXC.privileged = true;
      proxmoxLXC.manageNetwork = true;
      networking.useHostResolvConf = false;
      services.fstrim.enable = false; # Let Proxmox host handle fstrim

      environment.systemPackages = with pkgs; [ kmod ];

      services.uptime-kuma = {
        enable = true;
        settings = {
          UPTIME_KUMA_HOST = "127.0.0.1";
          UPTIME_KUMA_PORT = "3001";
        };
      };

      systemd.services.uptime-kuma.path = [ pkgs.cloudflared ];

      services.godel = {
        overlay = {
          enable = true;
          ip = infra_node_ip;
        };
        k3s = {
          enable = true;
          node-ip = infra_node_ip;
          role = "agent";
        };
      };
    };
}
