{ pkgs, lib }:

let
  version = "1.17.14";
  src = pkgs.fetchFromGitHub {
    owner = "anomalyco";
    repo = "opencode";
    tag = "v${version}";
    sha256 = "sha256-Xm6PXDzRqHS66ERKTlhEfD9enrHOsZUaQPrfGD3/WqU=";
  };

  opencode' = pkgs.opencode.overrideAttrs (old: {
    inherit version src;
    node_modules = old.node_modules.overrideAttrs (oldModules: {
      inherit version src;
      outputHash = "sha256-9oSXcvvISB6WAqI6f/GBZ3i9IBwYrRQvKs82SLibJNo=";
    });
  });
in
pkgs.opencode-desktop.overrideAttrs (old: {
  inherit version src;
  node_modules = opencode'.node_modules;
  patches = [ ];
})
