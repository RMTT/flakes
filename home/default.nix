{
  home-manager,
  nixpkgs-fresh,
  ...
}@inputs:
let
  overlay-ownpkgs = platform: final: prev: inputs.self.packages.${platform};
in
{
  rmt = let platform = "aarch64-darwin";
  in home-manager.lib.homeManagerConfiguration {
    pkgs = import nixpkgs-fresh {
      system = platform;
      config.allowUnfree = true;
    };
    modules = [
      {
        nixpkgs.overlays = [
           (overlay-ownpkgs platform)
        ];
        programs.home-manager.enable = true;
      }
      inputs.nur.modules.homeManager.default
      inputs.sops-nix.homeManagerModules.sops
      {
        home.username = "rmt";
        home.homeDirectory =  "/Users/rmt" ;
        home.stateVersion = "26.11";
      }
      ./modules/base.nix
      ./modules/darwin
    ];
  };
}
