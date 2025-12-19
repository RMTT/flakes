{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
{
  imports = [
    ./homebrew.nix
    ./skhd.nix
    ../kitty.nix
  ];

  config = {
    programs.home-manager.enable = true;

    home.packages = with pkgs; [
      nerd-fonts.fira-code
      sshuttle
      lima # for running x86 vms and containers
      htop
      wget
      kitty
      age

      # dev tools
      cmake
      autoconf
      automake
      glibtool
      pkg-config
      gettext
      perl
      gperf
      flex
      bison
      rustup
      bear
      sops

      (pkgs.python3.withPackages (python-pkgs: [ ]))
    ];

  };
}
