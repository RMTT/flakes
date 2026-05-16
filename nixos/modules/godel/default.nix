{
  lib,
  ...
}:
{
  imports = [
    ./grafana
    ./k3s.nix
    ./overlay.nix
    ./prometheus
    ./uptime.nix
    ./wireguard.nix
  ];

  options = {
    services.godel = {
      infra-ip = lib.mkOption { type = lib.types.str; };
    };
  };
}
