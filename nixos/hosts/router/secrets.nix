{ modules, ... }: {

  imports =
    with modules; [ secrets ];

  sops.secrets.muconnect_key = {
    owner = "systemd-network";
    mode = "0400";
    sopsFile = ./secrets/muconnect.key;
    format = "binary";
  };

  sops.secrets.udp2raw = {
    mode = "0400";
    sopsFile = ./secrets/udp2raw;
    format = "binary";
  };

  sops.secrets.ups_pass = {
    mode = "0400";
    sopsFile = ./secrets/ups_pass;
    format = "binary";
  };

  sops.secrets.clash_config = {
    sopsFile = ./secrets/clash_config;
    format = "binary";
    mode = "644";
  };
}
