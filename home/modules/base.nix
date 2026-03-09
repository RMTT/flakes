{ pkgs, ... }:
{
  xdg.configFile."nixpkgs/config.nix".source = ../config/nixpkgs-config.nix;

  home.packages = with pkgs; [
    colmena
    (pkgs.wrapHelm pkgs.kubernetes-helm {
      plugins = with pkgs.kubernetes-helmPlugins; [
        helm-secrets
      ];
    })
  ];

  nix.settings = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://colmena.cachix.org"
      "https://cache.garnix.io"
    ];
    extra-trusted-public-keys = [
      "colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    warn-dirty = false;
  };
  nix.gc.automatic = true;
  nix.package = pkgs.nix;

  programs.docker-cli = {
    enable = true;
    settings = {
      "detachKeys" = "ctrl-a";
    };
  };
}
