{ config, lib, ... }:
with lib;
let
  cfg = config.machine.nix-config;
in
{
  options.machine.nix-config = {
    enable = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    # enable unfree pkgs
    nixpkgs.config.allowUnfree = true;

    nix.channel.enable = false;

    # binary cache
    nix.settings.substituters = [
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org"
      "https://mts-flakes.cachix.org"
    ];
    nix.settings.trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "mts-flakes.cachix.org-1:Gk59/na1GIp86A3aQODDwSDti43n+gIereKJ6a12dpk="
    ];
    nix.settings.trusted-users = [
      (mkIf config.machine.users.mt.enable "mt")
    ];
    nix.optimise.automatic = true;
    nix.gc.automatic = true;

    # enable flakes
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
}
