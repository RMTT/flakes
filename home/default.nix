{
  home-manager,
  nixpkgs-fresh,
  ...
}@inputs:
let
  system = builtins.currentSystem;
  overlay-ownpkgs = final: prev: inputs.self.packages.${system};
in
{
  mt = home-manager.lib.homeManagerConfiguration {
    pkgs = import nixpkgs-fresh {
      inherit system;
      config.allowUnfree = true;
    };
    extraSpecialArgs = {
      inherit system;
    };
    modules = [
      {
        nixpkgs.overlays = [ overlay-ownpkgs ];
        nixpkgs.config = {
          allowUnfree = true;
        };
        programs.home-manager.enable = true;
      }
      inputs.nur.modules.homeManager.default
      inputs.sops-nix.homeManagerModules.sops
      inputs.vicinae.homeManagerModules.default
      {
        home.username = "mt";
        home.homeDirectory = if (system == "aarch64-darwin") then "/Users/mt" else "/home/mt";
      }
      ./mt.nix
    ];
  };
}
