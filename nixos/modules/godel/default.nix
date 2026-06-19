{
  lib,
  ...
}:
{
  imports = [
    ./k3s
    ./tailscale.nix
    ./uptime.nix
    ./traefik.nix
    ./wireguard
    ./alloy
  ];

  options = {
    services.godel = {
      infra-ip = lib.mkOption { type = lib.types.str; };
    };
  };
}
