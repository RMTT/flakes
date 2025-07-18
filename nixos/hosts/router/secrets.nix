{ modules, ... }: {

  imports =
    with modules; [ secrets ];

  sops.secrets.muconnect_key = {
    owner = "systemd-network";
    mode = "0400";
    sopsFile = ./secrets/muconnect.key;
    format = "binary";
  };

  sops.secrets.ups_pass = {
    mode = "0400";
    sopsFile = ./secrets/ups_pass;
    format = "binary";
  };
}
