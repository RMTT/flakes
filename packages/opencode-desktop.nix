{ pkgs, lib }:

let
  version = "1.17.8";
  src = pkgs.fetchFromGitHub {
    owner = "anomalyco";
    repo = "opencode";
    tag = "v${version}";
    sha256 = "07rxmwn9w4zdyk8jjxgrfhzgbxa7jlbx2vyynf48692yh8a845w9";
  };

  opencode' = pkgs.opencode.overrideAttrs (old: {
    inherit version src;
    node_modules = old.node_modules.overrideAttrs (oldModules: {
      inherit version src;
      outputHash = "sha256-ERywlcNEF9EUW3JDGH8987g+GAj76RylUtegqMvStyg=";
    });
  });
in
pkgs.opencode-desktop.overrideAttrs (old: {
  inherit version src;
  node_modules = opencode'.node_modules;
  patches = [ ];
})
