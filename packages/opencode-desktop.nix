{ pkgs, lib }:

let
  version = "1.17.13";
  src = pkgs.fetchFromGitHub {
    owner = "anomalyco";
    repo = "opencode";
    tag = "v${version}";
    sha256 = "sha256-WE8+O+Od8M71fKoOOhE9CbTsJ0JMAi0ZajmYd//VG2k=";
  };

  opencode' = pkgs.opencode.overrideAttrs (old: {
    inherit version src;
    node_modules = old.node_modules.overrideAttrs (oldModules: {
      inherit version src;
      outputHash = "sha256-SUNfdHtASPh1mpxKvIKJ2GrDHAxmv7Gu7B7vr3PX5W4=";
    });
  });
in
pkgs.opencode-desktop.overrideAttrs (old: {
  inherit version src;
  node_modules = opencode'.node_modules;
  patches = [ ];
})
