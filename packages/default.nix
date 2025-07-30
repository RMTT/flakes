{ pkgs, ... }: {
  metacubexd = pkgs.callPackage ./metacubexd.nix { };
  derper = pkgs.callPackage ./derp.nix { };
  udp2raw = pkgs.callPackage ./udp2raw-bin.nix { };
  zoom-us = pkgs.callPackage ./zoom.nix { };
  cider = pkgs.callPackage ./cider2.nix { };
  kwin4-effect-geometry-change =
    pkgs.callPackage ./kwin4-effect-geometry-change.nix { };
  xdg-desktop-portal-gtk = pkgs.callPackage ./xdg-desktop-portal-gtk.nix { };
  aronet = pkgs.callPackage ./aronet { };
  gost = pkgs.callPackage ./gost.nix { };
  gost-ui = pkgs.callPackage ./gost-ui.nix { };
}
