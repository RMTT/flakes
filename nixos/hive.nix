{
  nixpkgs,
  nixpkgs-fresh,
  colmena,
  ...
}@inputs:
let
  overlay-ownpkgs =
    system: final: prev:
    inputs.self.packages.${system};

  commonModules = builtins.attrValues (import ./modules.nix);
in
colmena.lib.makeHive {
  meta = {
    name = "mt's machines";
    nixpkgs = import nixpkgs rec {
      system = "x86_64-linux";
      overlays = [ (overlay-ownpkgs system) ];
    };

    nodeNixpkgs = {
      mtspc = import nixpkgs-fresh rec {
        system = "x86_64-linux";
        overlays = [
          (overlay-ownpkgs system)
        ];
      };
    };
  };

  # apply to all nodes
  defaults = {
    imports = commonModules ++ [
      inputs.nur.modules.nixos.default
      inputs.sops-nix.nixosModules.sops
      inputs.home-manager.nixosModules.home-manager
      inputs.disko.nixosModules.disko
      inputs.determinate.nixosModules.default
      {
          nix.registry = builtins.mapAttrs (_: value: { flake = value; }) inputs;
      }
    ];
  };

  iso =
    { name, ... }:
    {
      deployment = {
        allowLocalDeployment = true;
        targetHost = null;
      };
      imports = [
        ./hosts/${name}
        "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-gnome.nix"
      ];
    };
  cn2-box =
    { name, ... }:
    {
      deployment = {
        targetHost = "${name}.rmtt.host";
        targetPort = 22;
        targetUser = "mt";
        buildOnTarget = true;
      };
      imports = [ ./hosts/${name} ];
      networking.hostName = name;
      networking.hostId = "196875cc";
    };
  kube-runner =
    { name, ... }:
    {
      deployment = {
        targetHost = "${name}.infra.rmtt.host";
        targetPort = 22;
        targetUser = "mt";
        buildOnTarget = true;
      };
      imports = [ ./hosts/${name} ];
      networking.hostName = name;
      networking.hostId = "33f2bdce";
    };
  labrouter =
    { name, ... }:
    {
      deployment = {
        targetHost = "${name}.infra.rmtt.host";
        targetPort = 22;
        targetUser = "mt";
        buildOnTarget = true;
      };
      imports = [ ./hosts/${name} ];
      networking.hostName = name;
      networking.hostId = "c6602989";
    };
  mtspc =
    { name, ... }:
    {
      deployment = {
        allowLocalDeployment = true;
        targetHost = null;
      };
      imports = [
        ./hosts/${name}
        inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
        inputs.nixos-hardware.nixosModules.common-cpu-amd-zenpower
        inputs.nixos-hardware.nixosModules.common-gpu-nvidia
        inputs.nixos-hardware.nixosModules.common-pc-laptop
        inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
        inputs.nixos-hardware.nixosModules.common-gpu-amd
      ];
      networking.hostName = name;
      networking.hostId = "6260b68c";
    };
}
