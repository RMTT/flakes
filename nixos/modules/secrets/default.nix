{ ... }:
let
  keyFilePath = "/var/lib/sops-nix/age";
in
{
  sops.defaultSopsFile = ./keys.yaml;
  sops.age.sshKeyPaths = [ ];
  sops.gnupg.sshKeyPaths = [ ];
  sops.age.keyFile = keyFilePath;
  sops.age.generateKey = false;
}
