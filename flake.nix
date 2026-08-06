{
  description = "mt's configuration of machines";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://mts-flakes.cachix.org"
      "https://install.determinate.systems"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "mts-flakes.cachix.org-1:Gk59/na1GIp86A3aQODDwSDti43n+gIereKJ6a12dpk="
      "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-fresh.url = "github:NixOS/nixpkgs/nixos-unstable";

    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";

    flake-utils.url = "github:numtide/flake-utils";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-fresh";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    nur.url = "github:nix-community/NUR";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      git-hooks-nix,
      ...
    }@inputs:
    with flake-utils.lib;
    {
      nixosConfigurations = import ./nixos inputs;
      nixosModules = import ./nixos/modules;
      homeConfigurations = import ./home inputs;
      snip = import ./nixos/snip.nix inputs;
    }
    // eachSystem [ system.x86_64-linux system.aarch64-linux ] (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        git-hooks = import ./git-hooks.nix { inherit pkgs git-hooks-nix; };
      in
      {
        packages = import ./packages {
          inherit inputs system;
        };
        checks = {
          pre-commit-check = git-hooks;
        };
        devShells.default = pkgs.mkShellNoCC {
          packages = with pkgs; [
            nodejs
            python3
            python3Packages.pip
            uv
            terraform
            jq
          ];
          shellHook = git-hooks.shellHook;
        };
      }
    );
}
