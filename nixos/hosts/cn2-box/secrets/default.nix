{ ... }:
{
  machine.secrets.enable = true;

  sops.secrets.godel-wg = {
    sopsFile = ./godel-wg;
    format = "binary";
  };
}
