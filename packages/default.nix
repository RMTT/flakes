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

  cf-terraforming = pkgs.cf-terraforming.overrideAttrs (
    final: prev: rec {
      version = "0.25.0";
      src = pkgs.fetchFromGitHub {
        owner = "cloudflare";
        repo = "cf-terraforming";
        rev = "v${version}";
        sha256 = "sha256-0OARocpj1bu7mpJurwB0IvyQEqbmhVnOa7wCrG1vQds=";
      };
    }
  );

  noctalia-shell = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
  colmena = inputs.colmena.packages.${system}.colmena;
}
