{
  nixpkgs,
  colmena,
  ...
}@inputs:
let
  overlay-ownpkgs =
    system: final: prev:
    inputs.self.packages.${system};

  commonModules = builtins.attrValues (import ./modules.nix);
  collectFlakeInputs =
    input:
    [ input ] ++ builtins.concatMap collectFlakeInputs (builtins.attrValues (input.inputs or { }));
in
colmena.lib.makeHive {
  meta = {
    name = "mt's machines";
    nixpkgs = import nixpkgs {
      system = "x86_64-linux";
      overlays = [ (overlay-ownpkgs "x86_64-linux") ];
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
      };
      imports = [ ./hosts/${name} ];
      networking.hostName = name;
      networking.hostId = "196875cc";
    };
  rack =
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
      networking.hostId = "d21a8b00";
    };
  de-hz =
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
      networking.hostId = "6cf6ea73";
    };
  homeserver =
    { name, ... }:
    {
      deployment = {
        targetHost = "${name}.java-crocodile.ts.net";
        targetPort = 22;
        targetUser = "mt";
        buildOnTarget = true;
      };
      imports = [ ./hosts/${name} ];
      networking.hostName = name;
      networking.hostId = "33f2bdce";
    };
}
