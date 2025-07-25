{
  description = "mt's configuration of machines";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-fresh.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-testing.url = "github:rmtt/nixpkgs";

    flake-utils.url = "github:numtide/flake-utils";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-fresh";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    nur.url = "github:nix-community/NUR";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixpkgs-fresh, flake-utils, ... }@inputs:
    with flake-utils.lib;
    let

      lib = import ./lib inputs;

      nixosConfigurations = {
        mtspc = lib.mkSystem "mtspc" system.x86_64-linux nixpkgs-fresh;
        mtslaptop = lib.mkSystem "mtslaptop" system.x86_64-linux nixpkgs-fresh;

        homeserver = lib.mkSystem "homeserver" system.x86_64-linux nixpkgs;

        router = lib.mkSystem "router" system.x86_64-linux nixpkgs;

        cn2-la = lib.mkSystem "cn2-la" system.x86_64-linux nixpkgs;

        cn2-box = lib.mkSystem "cn2-box" system.x86_64-linux nixpkgs;

        de-hz = lib.mkSystem "de-hz" system.x86_64-linux nixpkgs;

        # for nixd language server
        nixd = lib.mkSystem "nixd" system.x86_64-linux nixpkgs;

        # for testing
        test = lib.mkSystem "test" system.x86_64-linux inputs.nixpkgs-testing;
      };

      homeConfigurations = {
        mt = lib.mkUser "mt" system.x86_64-linux nixpkgs-fresh;
        darwin = lib.mkUser "mt" system.aarch64-darwin nixpkgs-fresh;
      };
    in {
      templates = import ./templates;

      nixosConfigurations = nixosConfigurations;
      homeConfigurations = homeConfigurations;
    } // eachSystem [ system.x86_64-linux ] (system:
      let
        pkgs = import nixpkgs {
          system = system;
          config.allowUnfree = true;
        };
      in {
        formatter = pkgs.nixpkgs-fmt;
        packages = import ./packages pkgs;
        devShells.default = pkgs.mkShell {
          packages =
            [ (pkgs.python3.withPackages (pypkgs: with pypkgs; [ requests ])) ];
        };
      });
}
