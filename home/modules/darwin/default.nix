{
  lib,
  pkgs,
  ...
}:
with lib;
{
  imports = [
    ./homebrew.nix
    ../ghostty.nix
    ../gpg.nix
  ];

  config = {
    programs.home-manager.enable = true;

    targets.darwin.copyApps.enable = true;
    targets.darwin.linkApps.enable = false;
    home.packages = with pkgs; [
      nh
      ssh-to-age
      gitui
      sshuttle
      lima # for running x86 vms and containers
      htop
      wget
      age
      sops
      fastfetch
      usbutils
      kubectl


      (pkgs.python3.withPackages (python-pkgs: [ ]))
      nodejs
      docker
    ];
  };
}
