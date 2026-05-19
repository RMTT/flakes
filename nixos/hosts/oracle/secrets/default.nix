{ ... }:
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
  sops.secrets.grafana-secret = {
    sopsFile = ./grafana-secret;
    format = "binary";
    owner = "grafana";
  };
  sops.secrets.traefik-env = {
    sopsFile = ./traefik-env;
    format = "binary";
  };
}
