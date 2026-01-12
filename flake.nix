{
  description = "mt's configuration of machines";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-fresh.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-testing.url = "github:rmtt/nixpkgs";

    flake-utils.url = "github:numtide/flake-utils";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-fresh";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    nur.url = "github:nix-community/NUR";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    colmena.url = "github:zhaofengli/colmena";
    colmena.inputs.nixpkgs.follows = "nixpkgs-fresh";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }@inputs:
    with flake-utils.lib;
    rec {
      templates = import ./templates;

      colmenaHive = import ./nixos/hive.nix inputs;
      nixosConfigurations = colmenaHive.nodes;
      nixosModules = import ./nixos/modules.nix;
      homeConfigurations = import ./home inputs;
    }
    // eachSystem [ system.x86_64-linux system.aarch64-darwin ] (
      system:
      let
        pkgs = import nixpkgs {
          system = system;
          config.allowUnfree = true;
          config.cudaSupport = true;
        };
      in
      {
        formatter = pkgs.nixfmt;
        packages = (import ./packages { pkgs = pkgs; }) // {
          colmena = inputs.colmena.packages.${system}.colmena;
        };
        devShells.default = pkgs.mkShell {
          packages = [ (pkgs.python3.withPackages (pypkgs: with pypkgs; [ requests ])) ];
        };
      }
    );
}
