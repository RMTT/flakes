{ pkgs, lib }:

let
  version = "1.17.15";
  src = pkgs.fetchFromGitHub {
    owner = "anomalyco";
    repo = "opencode";
    tag = "v${version}";
    sha256 = "sha256-h4fmNEzRDBIXcFg58epM9Opot8n4zpE+8xy2J1/Q3UI=";
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
