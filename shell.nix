nixpkgs:
let
  pkgs = import nixpkgs {
    system = builtins.currentSystem;
    config = {
      allowUnfree = true;
    };
  };
in
pkgs.mkShellNoCC {
  packages = with pkgs; [
    nodejs
    python3
    python3Packages.pip
    uv
    terraform
  ];
}
