{ pkgs, lib }:

let
  version = "1.17.20";
  src = pkgs.fetchFromGitHub {
    owner = "anomalyco";
    repo = "opencode";
    tag = "v${version}";
    sha256 = "sha256-gHfkwCi6Kjn5ppsuyhyM2vyaLmAoNdWth6Xz4LaV7Hk=";
  };

  opencode' = pkgs.opencode.overrideAttrs (old: {
    inherit version src;
    node_modules = old.node_modules.overrideAttrs (oldModules: {
      inherit version src;
      outputHash = "sha256-3NAzmlzVBcLSRXxpNOyW5DKfD1i2HReST2jlKgrtOKc=";
    });
  });
in
pkgs.opencode-desktop.overrideAttrs (old: {
  inherit version src;
  node_modules = opencode'.node_modules;
})
