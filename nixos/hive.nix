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
  commonKeys = {
    "age" = {
      keyCommand = [
        "sops"
        "decrypt"
        "./keys/nixos_common.age"
      ];
      destDir = "/var/lib/sops-nix";
    };
  };

  collectFlakeInputs =
    input:
    [ input ] ++ builtins.concatMap collectFlakeInputs (builtins.attrValues (input.inputs or { }));
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
        overlays = [ (overlay-ownpkgs system) ];
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
      {
        system.extraDependencies = builtins.concatMap collectFlakeInputs (builtins.attrValues inputs);
        # pin registry
        nix.registry = builtins.mapAttrs (name: value: { flake = value; }) inputs;
        nix.channel.enable = false;
      }
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
        keys = commonKeys;
      };
      imports = [ ./hosts/${name} ];
      networking.hostName = name;
      networking.hostId = "196875cc";
    };
  kube-edge =
    { name, ... }:
    {
      deployment = {
        targetHost = "${name}.rmtt.host";
        targetPort = 22;
        targetUser = "mt";
        buildOnTarget = true;
        keys = commonKeys;
      };
      imports = [ ./hosts/${name} ];
      networking.hostName = name;
      networking.hostId = "d21a8b00";
    };
  kube-runner =
    { name, ... }:
    {
      deployment = {
        targetHost = "${name}.home.rmtt.host";
        targetPort = 22;
        targetUser = "mt";
        buildOnTarget = true;
        keys = commonKeys;
      };
      imports = [ ./hosts/${name} ];
      networking.hostName = name;
      networking.hostId = "33f2bdce";
    };
  mtspc =
    { name, ... }:
    {
      deployment = {
        allowLocalDeployment = true;
        targetHost = null;
      };
      imports = [ ./hosts/${name} ];
      networking.hostName = name;
      networking.hostId = "6260b68c";
    };
}
