{ pkgs, lib }:

let
  version = "1.17.18";
  src = pkgs.fetchFromGitHub {
    owner = "anomalyco";
    repo = "opencode";
    tag = "v${version}";
    sha256 = "sha256-Y0rcO6r9yqhYux8IS5oAtgzcMXfJE8I1Lre4HdJ5nBg=";
  };

  opencode' = pkgs.opencode.overrideAttrs (old: {
    inherit version src;
    node_modules = old.node_modules.overrideAttrs (oldModules: {
      inherit version src;
      outputHash = "sha256-kXdXw264JQdlNoZPv5GUyWZvb/A8h2CTRdiX79jyvys=";
    });
  });
in
pkgs.opencode-desktop.overrideAttrs (old: {
  inherit version src;
  node_modules = opencode'.node_modules;
  patches = [ ];
})
