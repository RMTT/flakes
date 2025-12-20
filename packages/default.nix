{ pkgs, ... }:
{
  cider = pkgs.callPackage ./cider2.nix { };
  aronet = pkgs.callPackage ./aronet { };
  gost = pkgs.callPackage ./gost.nix { };
  gost-ui = pkgs.callPackage ./gost-ui.nix { };
}
