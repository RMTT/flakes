{ inputs, system, ... }:
let
  pkgs = import inputs.nixpkgs {
    system = system;
    config.allowUnfree = true;
    config.cudaSupport = true;
  };
in
{
  sblite = pkgs.callPackage ./sblite.nix { };
  virtme-ng = pkgs.callPackage ./virtme-ng { };
  antigravity = pkgs.callPackage ./antigravity.nix { };
  opencode-desktop = pkgs.callPackage ./opencode-desktop.nix { };
  zsh-patina = pkgs.callPackage ./zsh-patina.nix { };

  noctalia-shell = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
  celler = inputs.celler.packages.${system}.default;
}
