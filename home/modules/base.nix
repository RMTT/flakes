{ pkgs, ... }:
{
  xdg.configFile."nixpkgs/config.nix".source = ../config/nixpkgs-config.nix;

  home.packages = with pkgs; [ colmena ];

  nix.settings = {
    substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://nix-community.cachix.org"
      "https://colmena.cachix.org"
    ];
    trusted-public-keys = [
      "colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    warn-dirty = false;
  };
  nix.gc.automatic = true;
  nix.package = pkgs.nix;
}
