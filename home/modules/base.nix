{
  config,
  pkgs,
  lib,
  ...
}:
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
      detachKeys = "ctrl-x";
      currentContext = "lima";
    };
    contexts = lib.mkIf pkgs.stdenv.isDarwin {
      lima = {
        Endpoints.docker.Host = "unix://${config.home.homeDirectory}/.lima/default/sock/docker.sock";
      };
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
