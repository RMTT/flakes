{
  pkgs,
  config,
  lib,
  system,
  ...
}:
{
  imports = [
    ./modules/base.nix
    ./modules/shell.nix
    ./modules/neovim.nix
    ./modules/git.nix
    ./modules/kitty.nix
    ./modules/gitui.nix
    ./modules/tmux.nix
    ./modules/ai.nix
    ./modules/kube.nix
    ./secrets

    # darwin modules
    (if (system == "aarch64-darwin") then ./modules/darwin else ./modules/linux)
  ];

  home.stateVersion = "23.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = lib.mkIf (config.nixpkgs.system == "aarch64-darwin") (
    lib.mkForce false
  );

  # direnv configuration
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  editorconfig = {
    enable = true;
    settings = {
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        serverAliveInterval = 60;
        serverAliveCountMax = 3;
      };
    };
  };
}
