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
    inputs.celler.nixosModules.cellerd
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
  cn2-box = mkNixOS "cn2-box" { };
  kube-runner = mkNixOS "kube-runner" { };
  agent = mkNixOS "agent" { };
  nextcloud = mkNixOS "nextcloud" { };

  mtspc = mkNixOS "mtspc" {
    nixpkgs = inputs.nixpkgs-fresh;
    extraModules = [
      inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
      inputs.nixos-hardware.nixosModules.common-cpu-amd-zenpower
      inputs.nixos-hardware.nixosModules.common-gpu-nvidia
      inputs.nixos-hardware.nixosModules.common-pc-laptop
      inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
      inputs.nixos-hardware.nixosModules.common-gpu-amd
    ];
  };

  iso = mkNixOS "iso" rec {
    nixpkgs = inputs.nixpkgs;
    extraModules = [
      "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-gnome.nix"
    ];
  };
}
