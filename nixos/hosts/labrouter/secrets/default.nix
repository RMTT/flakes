{ ... }:
{
  machine.secrets.enable = true;

  sops.secrets.traefik-env = {
    sopsFile = ./traefik-env;
    format = "binary";
  };
}
