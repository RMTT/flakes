{ ... }:
{
  machine.secrets.enable = true;
  sops.secrets.godel = {
    sopsFile = ./godel;
    format = "binary";
  };
}
