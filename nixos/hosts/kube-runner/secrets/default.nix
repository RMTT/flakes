{ ... }:
{
  machine.secrets.enable = true;

  sops.secrets.godel-wg = {
    sopsFile = ./godel-wg.enc;
    format = "binary";
  };

  sops.secrets.restic-pass = {
    sopsFile = ./restic-pass.enc;
    format = "binary";
  };
  sops.secrets.restic-repo = {
    sopsFile = ./restic-repo.enc;
    format = "binary";
  };
  sops.secrets.restic-env = {
    sopsFile = ./restic-env.enc;
    format = "binary";
  };
}
