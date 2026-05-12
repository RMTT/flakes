{
  nixpkgs,
  system,
  hostPkgs,
}:
let
  system = nixpkgs.lib.nixosSystem {
    modules = [
      "${nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix"
      (
        { config, pkgs, ... }:
        {
          system.stateVersion = "26.05";
          nixpkgs.hostPlatform = "aarch64-linux";
          nix.settings.experimental-features = [
            "nix-command"
            "flakes"
          ];
          networking.hostName = "armer";

          services.openssh.enable = true;

          security.sudo.wheelNeedsPassword = false;
          virtualisation.docker.enable = true;

          users.users.mt = {
            isNormalUser = true;
            extraGroups = [
              "wheel"
              "docker"
            ];
            initialPassword = "123456";
            openssh.authorizedKeys.keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHBjkW0ansGOkZCBkjyf5RArK+Amtxw7W/FeNV6GaRfG"
            ];
          };

          environment.systemPackages = with pkgs; [
            git
            go
            sshfs
            gcc
          ];

          virtualisation.sharedDirectories = {
            cwd = {
              source = "/home/mt/Projects/gost";
              target = "/home/mt/share";
            };
          };

          virtualisation.forwardPorts = [
            { from = "host"; host.port = 2222; guest.port = 22; }
          ];
          virtualisation.graphics = false;
          virtualisation.diskSize = 20480;
          virtualisation.memorySize = 8196;
          virtualisation.cores = 8;
          virtualisation.host.pkgs = hostPkgs;
          virtualisation.qemu.options = [
            "-nographic"
            "-machine virt"
            "-serial mon:stdio"
            "-cpu max"
          ];
        }
      )
    ];
  };
in
  system.config.system.build.vm
