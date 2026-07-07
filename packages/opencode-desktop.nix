{ pkgs, lib }:

let
  version = "1.17.14";
  src = pkgs.fetchFromGitHub {
    owner = "anomalyco";
    repo = "opencode";
    tag = "v${version}";
    sha256 = "sha256-BJedhjv4+Dn1pmuGd79qPwrO18nMUPUYDiyfrVbLUMk=";
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
