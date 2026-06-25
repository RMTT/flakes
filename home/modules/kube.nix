{ config, ... }:
{
  sops.secrets.kube = {
    sopsFile = ../config/kube/secrets/config;
    format = "binary";
    path = "${config.home.homeDirectory}/.kube/config";
  };
}
