{
  lib,
  ...
}:
{
  imports = [
    ./k3s
    ./overlay.nix
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
