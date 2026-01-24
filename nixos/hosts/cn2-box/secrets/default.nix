{ ... }:
{
  machine.secrets.enable = true;
  sops.secrets.singbox = {
    mode = "0400";
    sopsFile = ./config.json;
    format = "binary";
  };
}
