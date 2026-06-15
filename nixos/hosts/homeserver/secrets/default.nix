{ config, ... }:
{
  machine.secrets.enable = true;
  sops.secrets.traefik-env = {
    sopsFile = ./traefik-env;
    format = "binary";
  };

  sops.secrets.restic-repo = {
    sopsFile = ./restic-repo;
    format = "binary";
  };
  sops.secrets.restic-pass = {
    sopsFile = ./restic-pass;
    format = "binary";
  };
}
