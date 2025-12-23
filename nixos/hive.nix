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
  kube-master =
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
  homeserver =
    { name, ... }:
    {
      deployment = {
        targetHost = "${name}.java-crocodile.ts.net";
        targetPort = 22;
        targetUser = "mt";
        buildOnTarget = true;
        keys = commonKeys;
      };
      imports = [ ./hosts/${name} ];
      networking.hostName = name;
      networking.hostId = "33f2bdce";
    };
  router =
    { name, ... }:
    {
      deployment = {
        targetHost = "${name}.java-crocodile.ts.net";
        targetPort = 22;
        targetUser = "mt";
        buildOnTarget = true;
        keys = commonKeys;
      };
      imports = [ ./hosts/${name} ];
      networking.hostName = name;
      networking.hostId = "b551a88a";
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
