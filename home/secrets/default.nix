{ config, ... }:
let
  keyFilePath = "${config.home.homeDirectory}/.config/sops-nix/age";
in
{
  sops.age.keyFile = keyFilePath;
  sops.defaultSopsFile = ./keys.yaml;
}
