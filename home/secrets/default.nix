{ config, ... }:
{
  sops.age.sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
  sops.defaultSopsFile = ./keys.yaml;
}
