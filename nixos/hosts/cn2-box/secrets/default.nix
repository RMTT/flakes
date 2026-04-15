{ ... }:
{
  machine.secrets.enable = true;

  sops.secrets.tunnel = {
    sopsFile = ./tunnel.token;
    format = "binary";
  };
}
