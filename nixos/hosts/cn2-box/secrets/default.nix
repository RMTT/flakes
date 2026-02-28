{ ... }:
{
  machine.secrets.enable = true;

  sops.secrets.godel = {
    sopsFile = ./godel;
    format = "binary";
  };
  sops.secrets.ss = {
    sopsFile = ./godel;
    format = "binary";
  };
}
