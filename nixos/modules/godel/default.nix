{
  lib,
  ...
}:
{
  imports = [
    ./k3s
    ./tailscale
    ./uptime.nix
    ./traefik.nix
    ./wireguard
    ./alloy
    ./dummy.nix
  ];

  options = {
    services.godel = {
      infra-ip = lib.mkOption { type = lib.types.str; };
    };
  };
}
