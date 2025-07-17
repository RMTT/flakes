{ modules, ... }: {
  imports = with modules; [ secrets ];

  sops.secrets.singbox = {
    mode = "0400";
    sopsFile = ./singbox.json;
    format = "binary";
  };
  sops.secrets.clash = {
    mode = "0400";
    sopsFile = ./clash;
    format = "binary";
  };
}
