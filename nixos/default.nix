{
  ...
}@inputs:
let
  overlay-ownpkgs =
    system: final: prev:
    inputs.self.packages.${system};

  ownModules = builtins.attrValues (import ./modules);
  commonModules = ownModules ++ [
    inputs.nur.modules.nixos.default
    inputs.sops-nix.nixosModules.sops
    inputs.home-manager.nixosModules.home-manager
    inputs.disko.nixosModules.disko
    inputs.determinate.nixosModules.default
    inputs.cardwire.nixosModules.default
    (
      { config, lib, ... }:
      {
        nixpkgs.overlays = [ (overlay-ownpkgs config.nixpkgs.hostPlatform.system) ];
        nix.registry = lib.mkForce (lib.mapAttrs (_: value: { flake = value; }) inputs);
      }
    )
  ];

  mkNixOS =
    name:
    {
      nixpkgs ? inputs.nixpkgs,
      extraModules ? [ ],
    }:
    nixpkgs.lib.nixosSystem {
      modules =
        commonModules
        ++ extraModules
        ++ [
          ./hosts/${name}
          {
            networking.hostName = name;
          }
        ];
    };
in
{
  oracle = mkNixOS "oracle" { };
  kube-runner = mkNixOS "kube-runner" { };
  cn2-box = mkNixOS "cn2-box" { };
}
