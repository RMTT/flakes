{
  lib,
  ...
}:
{
  imports = [
    ./k3s
    ./tailscale
    ./traefik.nix
    ./wireguard
    ./alloy
    ./dummy.nix
    ./dns
  ];

  options = {
    services.godel = {
      infra-ip = lib.mkOption { type = lib.types.str; };
      external-ip = lib.mkOption {
        type = lib.types.str or null;
        default = null;
        description = "use external-ip as flannel endpoint";
      };
    };
  };
}
