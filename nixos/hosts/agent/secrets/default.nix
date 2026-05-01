{ ... }: {

  machine.secrets.enable = true;

  sops.secrets.env = {
    sopsFile = ./env;
    format = "binary";
  };
}
