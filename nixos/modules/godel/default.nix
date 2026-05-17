{
  lib,
  ...
}:
{
  imports = [
    ./grafana
    ./k3s
    ./overlay.nix
    ./prometheus
    ./uptime.nix
    ./wireguard
  ];

  options = {
    services.godel = {
      infra-ip = lib.mkOption { type = lib.types.str; };
    };
  };
}
