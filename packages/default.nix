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
  zsh-patina = pkgs.callPackage ./zsh-patina.nix { };

  noctalia-shell = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
  celler = inputs.celler.packages.${system}.default;

  # aarch64 vm
  armer = import ./armer.nix {
    nixpkgs = inputs.nixpkgs;
    hostPkgs = pkgs;
    inherit system;
  };
}
