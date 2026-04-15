{ config, ... }:
{
  sops.secrets.kube = {
    sopsFile = ../config/kube/config;
    format = "binary";
    path = "${config.home.homeDirectory}/.kube/config";
  };
}
