{ modules, ... }:
{
  imports = with modules; [ secrets ];

  sops.secrets.singbox = {
    mode = "0400";
    sopsFile = ./config.json;
    format = "binary";
  };
}
