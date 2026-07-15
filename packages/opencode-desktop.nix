{ pkgs, lib }:

let
  version = "1.18.1";
  src = pkgs.fetchFromGitHub {
    owner = "anomalyco";
    repo = "opencode";
    tag = "v${version}";
    sha256 = "sha256-ESKM2u46KQI5wq736D2RTd8IZH2SdOKtGUCDnMJQGVc=";
  };

  opencode' = pkgs.opencode.overrideAttrs (old: {
    inherit version src;
    node_modules = old.node_modules.overrideAttrs (oldModules: {
      inherit version src;
      outputHash = "sha256-1NUtprMH8GnSUqQ+mHQSC+JLU7lwzHe6XXYHe129WmE=";
    });
  });
in
pkgs.opencode-desktop.overrideAttrs (old: {
  inherit version src;
  node_modules = opencode'.node_modules;
})
