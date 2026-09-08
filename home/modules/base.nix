{ pkgs, ... }:
{
  imports = [
    ./shell.nix
    ./neovim.nix
    ./git.nix
    ./gitui.nix
    ./zellij.nix
    ./agents.nix
    ./kube.nix
    ../secrets

  ];

  programs.docker-cli = {
    enable = true;
    settings = {
      "detachKeys" = "ctrl-x";
    };
  };
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
    settings = {
      "*" = {
        serverAliveInterval = 60;
        serverAliveCountMax = 3;
      };
    };
  };
}
