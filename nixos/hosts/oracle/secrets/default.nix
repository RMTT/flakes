{ config, ... }:
{
  machine.secrets.enable = true;

  sops.secrets.tunnel = {
    sopsFile = ./tunnel;
    format = "binary";
  };
  sops.secrets.godel-wg = {
    sopsFile = ./godel-wg;
    format = "binary";
  };
  # sops.secrets.grafana-secret = {
  #   sopsFile = ./grafana-secret;
  #   format = "binary";
  #   owner = "grafana";
  # };
  sops.secrets.traefik-env = {
    sopsFile = ./traefik-env;
    format = "binary";
  };

  sops.secrets.restic-pass = {
    sopsFile = ./restic-pass;
    format = "binary";
  };
  sops.secrets.restic-repo = {
    sopsFile = ./restic-repo;
    format = "binary";
  };
  sops.secrets.restic-env = {
    sopsFile = ./restic-env;
    format = "binary";
  };
}
